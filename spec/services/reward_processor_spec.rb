# frozen_string_literal: true

RSpec.describe DiscourseKofi::RewardProcessor do
  fab!(:account) { Fabricate(:kofi_account) }
  fab!(:payment) { Fabricate(:kofi_payment, account: account) }
  fab!(:subscription) { Fabricate(:kofi_subscription, account: account) }

  fab!(:account2) { Fabricate(:kofi_account) }
  fab!(:payment2) { Fabricate(:kofi_payment, account: account2) }

  fab!(:payment3) { Fabricate(:kofi_payment) }

  fab!(:reward) do
    Fabricate(:kofi_reward, payment_types: %i[donation subscription])
  end

  it "will schedule payments reprocessing matching a reward" do
    allow(::Jobs).to receive(:enqueue)

    DiscourseKofi::RewardProcessor.reprocess(reward)

    expect(::Jobs).to have_received(:enqueue)
      .once
      .with(
        DiscourseKofi::Jobs::RewardUser,
        { payment_id: subscription.id, reward_id: reward.id }
      )
      .once
      .with(
        DiscourseKofi::Jobs::RewardUser,
        { payment_id: payment2.id, reward_id: reward.id }
      )

    expect(::Jobs).to_not have_received(:enqueue).with(
      DiscourseKofi::Jobs::RewardUser,
      { payment_id: payment.id }
    ).with(DiscourseKofi::Jobs::RewardUser, { payment_id: payment3.id })
  end
end
