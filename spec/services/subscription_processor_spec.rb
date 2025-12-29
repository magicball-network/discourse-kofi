# frozen_string_literal: true

RSpec.describe DiscourseKofi::SubscriptionProcessor do
  let(:account) { Fabricate(:kofi_account) }
  let(:reward) { Fabricate(:kofi_subscription_reward) }
  let(:payment) do
    Fabricate(
      :kofi_subscription,
      account: account,
      tier_name: reward.tier_name,
      timestamp: DateTime.now - 32.days
    )
  end
  let(:sub) do
    sub = DiscourseKofi::Subscription.new
    sub.user = payment.user
    sub.reward = reward
    sub.last_payment = payment
    sub.update_rewarded_fields
    sub.save!
    reward.group.add(sub.user)
    sub
  end

  it "removes group membership on expired subscription" do
    sub_count = DiscourseKofi::Subscription.where(user: sub.user).count
    expect(sub_count).to eq(1)
    group = GroupUser.find_by(group: sub.group, user: sub.user)
    expect(group).not_to be_nil

    described_class.expire_subscription(sub)

    group = GroupUser.find_by(group: sub.group, user: sub.user)
    expect(group).to be_nil

    expect(sub.user.notifications).to include(
      have_attributes(
        notification_type: Notification.types[:kofi_subscription_expired],
        data: { tier_name: reward.tier_name }.to_json
      ),
      have_attributes(
        notification_type: Notification.types[:kofi_subscription_left_group],
        data: {
          tier_name: reward.tier_name,
          group_id: reward.group.id,
          group_name: reward.group.name
        }.to_json
      )
    )
  end

  it "does not remove group membership on additional subscription" do
    sub2 = DiscourseKofi::Subscription.new
    sub2.user = sub.user
    sub2.reward = Fabricate(:kofi_subscription_reward, group: reward.group)
    sub2.last_payment =
      Fabricate(
        :kofi_subscription,
        account: account,
        tier_name: sub2.reward.tier_name
      )
    sub2.update_rewarded_fields
    sub2.save!

    sub_count = DiscourseKofi::Subscription.where(user: sub.user).count
    expect(sub_count).to eq(2)
    group = GroupUser.find_by(group: sub.group, user: sub.user)
    expect(group).not_to be_nil

    described_class.expire_subscription(sub)

    group = GroupUser.find_by(group: sub.group, user: sub.user)
    expect(group).not_to be_nil

    expect(sub.user.notifications).to include(
      have_attributes(
        notification_type: Notification.types[:kofi_subscription_expired],
        data: { tier_name: reward.tier_name }.to_json
      )
    )
    # Did not leave any group
    expect(sub.user.notifications).not_to include(
      have_attributes(
        notification_type: Notification.types[:kofi_subscription_left_group]
      )
    )
  end

  it "destroys subscriptions" do
    described_class.destroy!(sub)

    found_sub = DiscourseKofi::Subscription.find_by_id(sub.id)
    expect(found_sub).to be_nil

    group = GroupUser.find_by(group: sub.group, user: sub.user)
    expect(group).to be_nil
  end
end
