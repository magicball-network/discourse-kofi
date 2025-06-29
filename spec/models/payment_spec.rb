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
    ).to eq "https://ko-fi.com/Home/CoffeeShop?txid=00000000-1111-2222-3333-444444444444"
    expect(payment.email).to eq "jo.example@kofi.example"
    expect(payment.currency).to eq "USD"
    expect(payment.is_subscription_payment).to be true
    expect(payment.is_first_subscription_payment).to be true
    expect(
      payment.kofi_transaction_id
    ).to eq "00000000-1111-2222-3333-444444444444"
    expect(payment.tier_name).to eq "Gold"

    expect(payment.test_transaction?).to be true
    expect(payment.type_donation?).to be true

    expect(payment.save).to eq true

    stored_payment = ::DiscourseKofi::Payment.find(payment.id)
    expect(stored_payment.message_id).to eq payment.message_id
    expect(stored_payment.payment_type).to eq "donation"
    expect(stored_payment.verification_token).to be_nil
  end

  it "will set the user based on the account" do
    account = Fabricate(:account)
    payment = Fabricate(:payment)

    payment.account = account
    expect(payment.user).to be account.user

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
end
