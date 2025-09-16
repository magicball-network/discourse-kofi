# frozen_string_literal: true

RSpec.describe DiscourseKofi::Anonymizer do
  fab!(:user)
  fab!(:account) { Fabricate(:kofi_account, user: user) }
  fab!(:payment) { Fabricate(:kofi_payment, account: account) }

  it "anonymizes an existing account" do
    original_email = account.email
    DiscourseKofi::Anonymizer.anonymize_account(account)

    reloaded_account = DiscourseKofi::Account.find(account.id)
    expect(reloaded_account.anonymized).to be true
    expect(reloaded_account.email).not_to eq original_email
    expect(reloaded_account.user).to be_nil

    reloaded_payment = DiscourseKofi::Payment.find(payment.id)
    expect(reloaded_payment.anonymized).to be true
    expect(reloaded_payment.email).to eq reloaded_account.email
    expect(reloaded_payment.user).to be_nil
  end

  it "anonymizes an existing account base on payment email" do
    original_email = account.email
    account =
      DiscourseKofi::Anonymizer.anonymize_payments(original_email.upcase)
    expect(account).not_to be_nil

    reloaded_account = DiscourseKofi::Account.find(account.id)
    expect(reloaded_account.anonymized).to be true
    expect(reloaded_account.email).not_to eq original_email
    expect(reloaded_account.user).to be_nil

    reloaded_payment = DiscourseKofi::Payment.find(payment.id)
    expect(reloaded_payment.anonymized).to be true
    expect(reloaded_payment.email).to eq reloaded_account.email
    expect(reloaded_payment.user).to be_nil
  end

  it "creates an anonymized account for a payment" do
    payment2 = Fabricate(:kofi_payment)
    original_email = payment2.email
    DiscourseKofi::Anonymizer.anonymize_payments(original_email.upcase)

    reloaded_payment = DiscourseKofi::Payment.find(payment2.id)
    expect(reloaded_payment.anonymized).to be true
    expect(reloaded_payment.email).not_to eq original_email
    expect(reloaded_payment.user).to be_nil
    expect(reloaded_payment.account).not_to be_nil
    expect(reloaded_payment.account.anonymized).to be true
  end

  it "anonymized all accounts of a user" do
    DiscourseKofi::Anonymizer.anonymize_user(user)

    reloaded_account = DiscourseKofi::Account.find(account.id)
    expect(reloaded_account.anonymized).to be true
    expect(reloaded_account.user).to be_nil

    reloaded_payment = DiscourseKofi::Payment.find(payment.id)
    expect(reloaded_payment.anonymized).to be true
    expect(reloaded_payment.email).to eq reloaded_account.email
    expect(reloaded_payment.user).to be_nil
  end

  it "defers payment anonymization when there are many" do
    10.times { Fabricate(:kofi_payment, account: account) }

    allow(::Jobs).to receive(:enqueue)

    DiscourseKofi::Anonymizer.anonymize_account(account)

    expect(::Jobs).to have_received(:enqueue).with(
      DiscourseKofi::Jobs::AnonymizePayments,
      { account_id: account.id }
    )
  end

  it "does not anonymize invalid email addresses" do
    result =
      DiscourseKofi::Anonymizer.anonymize_payments("this is not a valid email")
    expect(result).to be_nil
  end
end
