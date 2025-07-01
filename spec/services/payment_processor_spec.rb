# frozen_string_literal: true

require "securerandom"

RSpec.describe DiscourseKofi::PaymentProcessor do
  let(:user) { Fabricate(:user) }
  let(:account) { Fabricate(:account, user: user) }
  let(:payment) { Fabricate(:payment) }

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
    reward = Fabricate(:reward)

    payment.account = account
    payment.amount = reward.amount + 1
    payment.save

    @proc.reward_user(payment)

    badge = UserBadge.find_by(badge: reward.badge, user: account.user)
    expect(badge).not_to be_nil
  end

  it "reward joins a user to a group" do
    reward = Fabricate(:reward)
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

  it "will not reward an anonymized payment" do
    reward = Fabricate(:reward)

    payment.account = account
    payment.amount = reward.amount + 1
    payment.save

    payment.make_anonymous
    @proc.reward_user(payment)

    badge = UserBadge.find_by(badge: reward.badge, user: account.user)
    expect(badge).to be_nil
  end
end
