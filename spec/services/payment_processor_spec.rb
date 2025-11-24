# frozen_string_literal: true

require "securerandom"

RSpec.describe DiscourseKofi::PaymentProcessor do
  let(:user) { Fabricate(:user) }
  let(:account) { Fabricate(:kofi_account, user: user) }
  let(:payment) { Fabricate(:kofi_payment) }

  before { @proc = DiscourseKofi::PaymentProcessor.new }

  it "returns a valid transaction id" do
    expect(
      @proc.extract_txid("00000000-1111-2222-3333-444444444444")
    ).to eq "00000000-1111-2222-3333-444444444444"
    expect(
      @proc.extract_txid(
        "https://ko-fi.com/Home/CoffeeShop?txid=00000000-1111-2222-3333-444444444444"
      )
    ).to eq "00000000-1111-2222-3333-444444444444"
    expect(
      @proc.extract_txid("ABCDEF00-1111-2222-3333-444444444444")
    ).to eq "abcdef00-1111-2222-3333-444444444444"

    expect(@proc.extract_txid("https://ko-fi.com/Home/CoffeeShop")).to be_nil
    expect(@proc.extract_txid("X0000000-1111-2222-3333-44444444444X")).to be_nil
    expect(@proc.extract_txid(nil)).to be_nil
  end

  it "allows a user to claim a payment" do
    payment.save

    result = @proc.claim_payment(user, payment.kofi_transaction_id)
    expect(result).to eq payment

    updated_payment = DiscourseKofi::Payment.find(payment.id)
    expect(updated_payment.account).not_to be_nil
    expect(updated_payment.user).to eq user
  end

  it "cannot claim a claimed payment" do
    payment.account = account
    payment.save

    expect {
      @proc.claim_payment(user, payment.kofi_transaction_id)
    }.to raise_error(
      an_instance_of(DiscourseKofi::PaymentClaimError).and having_attributes(
              failure: :already_claimed
            )
    )
  end

  it "cannot claim an unknown payment" do
    expect { @proc.claim_payment(user, SecureRandom.uuid) }.to raise_error(
      an_instance_of(DiscourseKofi::PaymentClaimError).and having_attributes(
              failure: :unknown_reference
            )
    )
  end

  it "cannot claim an an invalid reference" do
    expect { @proc.claim_payment(user, "invalid") }.to raise_error(
      an_instance_of(DiscourseKofi::PaymentClaimError).and having_attributes(
              failure: :invalid_reference
            )
    )
  end

  it "cannot claim an payment for an email linked to a different user" do
    account = Fabricate(:kofi_account)
    payment = Fabricate(:kofi_payment, email: account.email)

    expect {
      @proc.claim_payment(user, payment.kofi_transaction_id)
    }.to raise_error(
      an_instance_of(DiscourseKofi::PaymentClaimError).and having_attributes(
              failure: :account_failure
            )
    )
  end

  it "can resolve a payment via an existing account" do
    email = Faker::Internet.email
    payment.email = email
    payment.save
    account.email = email
    account.save

    @proc.resolve_payment(payment.id)
    updated_payment = ::DiscourseKofi::Payment.find(payment.id)
    expect(updated_payment.account).to eq account
    expect(updated_payment.user).to eq user
  end

  it "can resolve a payment via a new account" do
    email = Faker::Internet.email
    payment.email = email
    payment.save
    user.email = email
    user.save

    @proc.resolve_payment(payment.id)
    updated_payment = ::DiscourseKofi::Payment.find(payment.id)
    expect(updated_payment.account).not_to be_nil
    expect(updated_payment.account).not_to eq account
    expect(updated_payment.user).to eq user
  end

  it "will anonymize a payment when the account has been anonymized" do
    payment.email = account.email
    payment.save

    account.make_anonymous("12345@anonymous.invalid")
    account.save

    @proc.resolve_payment(payment.id)
    updated_payment = ::DiscourseKofi::Payment.find(payment.id)
    expect(updated_payment.account).to eq account
    expect(updated_payment.anonymized).to be true
    expect(updated_payment.from_name).to eq ""
    expect(updated_payment.email).to eq "12345@anonymous.invalid"
    expect(updated_payment.message).to eq ""
    expect(updated_payment.is_public).to be false
  end

  it "awards a user a badge" do
    reward = Fabricate(:kofi_reward)

    payment.account = account
    payment.amount = reward.amount + 1
    payment.save

    @proc.reward_user(payment)

    badge = UserBadge.find_by(badge: reward.badge, user: account.user)
    expect(badge).not_to be_nil
  end

  it "reward joins a user to a group" do
    reward = Fabricate(:kofi_reward)
    reward.badge = nil
    reward.group = Fabricate(:group)
    reward.save

    payment.account = account
    payment.amount = reward.amount + 1
    payment.save

    @proc.reward_user(payment)

    group = GroupUser.find_by(group: reward.group, user: account.user)
    expect(group).not_to be_nil
  end

  it "will only reward a single reward" do
    reward = Fabricate(:kofi_reward, amount: 10)
    reward.save
    reward2 = Fabricate(:kofi_reward, amount: 10)
    reward2.save

    payment.account = account
    payment.amount = 100
    payment.save

    @proc.reward_user(payment, reward)

    badge = UserBadge.find_by(badge: reward.badge, user: account.user)
    expect(badge).not_to be_nil

    badge = UserBadge.find_by(badge: reward2.badge, user: account.user)
    expect(badge).to be_nil
  end

  it "will not reward an anonymized payment" do
    reward = Fabricate(:kofi_reward)

    payment.account = account
    payment.amount = reward.amount + 1
    payment.save

    payment.make_anonymous
    @proc.reward_user(payment)

    badge = UserBadge.find_by(badge: reward.badge, user: account.user)
    expect(badge).to be_nil
  end

  describe "subscription rewards" do
    let(:sub_reward) { Fabricate(:kofi_subscription_reward) }
    let(:sub_payment) do
      Fabricate(
        :kofi_subscription,
        account: account,
        tier_name: sub_reward.tier_name
      )
    end

    it "will award a new subscription" do
      @proc.reward_user(sub_payment)

      sub = DiscourseKofi::Subscription.where(user: sub_payment.user).sole
      expect(sub.last_payment).to eq(sub_payment)
      expect(sub.reward).to eq(sub_reward)
      expect(sub.expired?).to be false

      group = GroupUser.find_by(group: sub_reward.group, user: account.user)
      expect(group).not_to be_nil
    end

    it "will reactivate an inactive subscription" do
      old_sub = DiscourseKofi::Subscription.new
      old_sub.user = sub_payment.user
      old_sub.last_payment =
        Fabricate(:kofi_subscription, timestamp: DateTime.now - 2.months)
      old_sub.reward = sub_reward
      old_sub.update_rewarded_fields
      old_sub.save
      expect(old_sub.expired?).to be true

      @proc.reward_user(sub_payment)

      sub = DiscourseKofi::Subscription.where(user: sub_payment.user).sole
      expect(sub.last_payment).to eq(sub_payment)
      expect(sub.expired?).to be false
    end

    it "will update subscription fields on re-award" do
      sub = DiscourseKofi::Subscription.new
      sub.user = sub_payment.user
      sub.last_payment = Fabricate(:kofi_subscription)
      sub.reward = sub_reward
      sub.update_rewarded_fields
      sub.save

      new_group = Fabricate(:group)
      sub_reward.tier_name = "new tier"
      sub_reward.group = new_group
      sub_reward.save
      sub_payment.tier_name = "New Tier"
      sub_payment.save

      @proc.reward_user(sub_payment)

      sub = DiscourseKofi::Subscription.where(user: sub_payment.user).sole
      expect(sub.tier_name).to eq("new tier")
      expect(sub.group).to eq(new_group)
    end

    it "will award multiple subscriptions" do
      @proc.reward_user(sub_payment)

      sub_reward2 = Fabricate(:kofi_subscription_reward)
      sub_reward2.tier_name = sub_reward.tier_name
      sub_reward2.save

      @proc.reward_user(sub_payment)

      subs = DiscourseKofi::Subscription.where(user: sub_payment.user)
      expect(subs).to contain_exactly(
        have_attributes(reward: sub_reward, last_payment: sub_payment),
        have_attributes(reward: sub_reward2, last_payment: sub_payment)
      )
    end

    it "will not award when tier does not match" do
      sub_reward.tier_name = "something else"
      sub_payment.tier_name = "not the same"
      @proc.reward_user(sub_payment, sub_reward)

      subs = DiscourseKofi::Subscription.where(user: sub_payment.user)
      expect(subs).to match_array([])
    end

    it "will not award subscription for non-subscription reward" do
      reward2 = Fabricate(:kofi_reward, group: Fabricate(:group))
      @proc.reward_user(sub_payment, reward2)

      subs = DiscourseKofi::Subscription.where(user: sub_payment.user)
      expect(subs).to match_array([])
    end

    it "only process a single reward" do
      sub_reward2 = Fabricate(:kofi_subscription_reward)
      sub_reward2.tier_name = sub_reward.tier_name
      sub_reward2.save

      @proc.reward_user(sub_payment, sub_reward2)

      sub = DiscourseKofi::Subscription.where(user: sub_payment.user).sole
      expect(sub.reward).to eq(sub_reward2)
    end
  end
end
