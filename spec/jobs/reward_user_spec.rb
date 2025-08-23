# frozen_string_literal: true

RSpec.describe DiscourseKofi::Jobs::RewardUser do
  before { SiteSetting.kofi_enabled = true }

  it "rewards a user for their payment" do
    payment = Fabricate(:kofi_payment)

    expect_any_instance_of(DiscourseKofi::PaymentProcessor).to receive(
      :reward_user
    ) do |instance, arg1, arg2|
      expect(arg1).to eq(payment)
      expect(arg2).to be_nil
    end

    described_class.new.execute({ payment_id: payment.id })
  end

  it "rewards a user for their payment for a given reward" do
    payment = Fabricate(:kofi_payment)
    reward = Fabricate(:kofi_reward)

    expect_any_instance_of(DiscourseKofi::PaymentProcessor).to receive(
      :reward_user
    ) do |instance, arg1, arg2|
      expect(arg1).to eq(payment)
      expect(arg2).to eq(reward)
    end

    described_class.new.execute(
      { payment_id: payment.id, reward_id: reward.id }
    )
  end

  it "it does nothing for an unresolved payment" do
    expect_any_instance_of(DiscourseKofi::PaymentProcessor).to_not receive(
      :reward_user
    )

    described_class.new.execute({ payment_id: 9_999_999_999 })
  end
end
