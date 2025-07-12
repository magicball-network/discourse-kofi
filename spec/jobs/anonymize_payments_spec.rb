# frozen_string_literal: true

RSpec.describe DiscourseKofi::Jobs::AnonymizePayments do
  before { SiteSetting.kofi_enabled = true }

  it "anonymized payments" do
    account = Fabricate(:account)
    payment1 = Fabricate(:payment, account: account)
    DiscourseKofi::Jobs::AnonymizePayments::BATCH_SIZE.times do
      Fabricate(:payment, account: account)
    end

    account.make_anonymous("1234@anonymous.invalid")
    account.save

    allow(::Jobs).to receive(:enqueue)

    described_class.new.execute({ account_id: account.id })

    reloaded_payment = DiscourseKofi::Payment.find(payment1.id)
    expect(reloaded_payment.anonymized).to be true

    expect(::Jobs).to have_received(:enqueue).with(
      described_class,
      include(account_id: account.id)
    )
  end

  it "does not anonymize if the account has not" do
    account = Fabricate(:account)
    payment = Fabricate(:payment, account: account)

    allow(::Jobs).to receive(:enqueue)

    described_class.new.execute({ account_id: account.id })

    reloaded_payment = DiscourseKofi::Payment.find(payment.id)
    expect(reloaded_payment.anonymized).to be false
  end
end
