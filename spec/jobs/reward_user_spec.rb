# frozen_string_literal: true

RSpec.describe DiscourseKofi::Jobs::RewardUser do
  before { SiteSetting.kofi_enabled = true }

  it "rewards a user for their payment" do
    payment = Fabricate(:kofi_payment)

    expect_any_instance_of(DiscourseKofi::PaymentProcessor).to receive(
      :reward_user
    ).with(payment)

    described_class.new.execute({ payment_id: payment.id })
  end
end
