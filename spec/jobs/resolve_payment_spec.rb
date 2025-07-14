# frozen_string_literal: true

RSpec.describe DiscourseKofi::Jobs::ResolvePayment do
  before { SiteSetting.kofi_enabled = true }

  it "resolves a payment" do
    account = Fabricate(:kofi_account)
    payment = Fabricate(:kofi_payment, email: account.email)

    described_class.new.execute({ payment_id: payment.id })

    reloaded_payment = DiscourseKofi::Payment.find(payment.id)
    expect(reloaded_payment.account).to eq account
  end
end
