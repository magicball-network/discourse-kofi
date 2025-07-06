# frozen_string_literal: true

RSpec.describe DiscourseKofi::Payment, type: :model do
  it "parses valid JSON" do
    json = plugin_file_fixture("webhook.json").read

    payment = ::DiscourseKofi::Payment.from_json(json)

    expect(
      payment.verification_token
    ).to eq "8cd88e1f-cf88-4dcc-9b66-75782b54ca70"
    expect(payment.message_id).to eq "bee3f4db-0ac1-442b-9a9b-5387a43a6b48"
    expect(payment.timestamp).to eq DateTime.iso8601("2025-05-17T08:08:19Z")
    expect(payment.type).to eq "Donation"
    expect(payment.is_public).to be true
    expect(payment.from_name).to eq "Jo Example"
    expect(payment.message).to eq "Just a unit test"
    expect(payment.amount).to eq 3.00
    expect(
      payment.url
    ).to eq "https://ko-fi.com/Home/CoffeeShop?txid=a8b80b8f-1df0-4a23-ba5f-67582b656bc9"
    expect(payment.email).to eq "jo.example@kofi.example"
    expect(payment.currency).to eq "USD"
    expect(payment.is_subscription_payment).to be true
    expect(payment.is_first_subscription_payment).to be true
    expect(
      payment.kofi_transaction_id
    ).to eq "a8b80b8f-1df0-4a23-ba5f-67582b656bc9"
    expect(payment.tier_name).to eq "Gold"

    expect(payment.test_transaction?).to be false
    expect(payment.type_donation?).to be true

    expect(payment.valid?).to be true
    expect(payment.save).to be true

    stored_payment = ::DiscourseKofi::Payment.find(payment.id)
    expect(stored_payment.message_id).to eq payment.message_id
    expect(stored_payment.payment_type).to eq "donation"
    expect(stored_payment.verification_token).to be_nil
    stored_payment.destroy
  end

  it "email is stored in lower case" do
    payment = Fabricate(:payment, email: "Mixed-Case-Email@Example.test")
    expect(payment.email).to eq "mixed-case-email@example.test"
  end

  it "will set the user based on the account" do
    account = Fabricate(:account)
    payment = Fabricate(:payment)

    payment.account = account
    expect(payment.user).to be account.user
    expect(payment.email).to eq account.email

    payment.account = nil
    expect(payment.user).to be_nil
  end

  it "aggregates payments" do
    account = Fabricate(:account)
    account.save

    Fabricate(:payment, account: account, amount: 5, type: "Donation").save
    Fabricate(:payment, account: account, amount: 10, type: "Donation").save
    Fabricate(:payment, account: account, amount: 15, type: "Subscription").save
    Fabricate(:payment, account: account, amount: 20, type: "Subscription").save
    Fabricate(:payment, amount: 9000, type: "Donation").save
    Fabricate(:payment, amount: 9000, type: "Subscription").save

    aggregate = ::DiscourseKofi::Payment.user_total(account.user)
    expect(aggregate["donation"]).to eq 15
    expect(aggregate["subscription"]).to eq 35
  end

  it "can anonymize a payment" do
    payment = Fabricate(:payment)
    payment.make_anonymous

    expect(payment.anonymized).to be true
    expect(payment.from_name).to eq ""
    expect(payment.message).to eq ""
    expect(payment.is_public).to be false
  end

  it "anonymized account makes payment anonymized" do
    account = Fabricate(:account)
    account.make_anonymous("12345@anonymous.invalid")
    payment = Fabricate(:payment)
    payment.account = account

    expect(payment.anonymized).to be true
    expect(payment.email).to eq "12345@anonymous.invalid"
  end
end
