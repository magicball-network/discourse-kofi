# frozen_string_literal: true

RSpec.describe DiscourseKofi::AdminPaymentSerializer do
  let(:payment) do
    Fabricate(:payment, amount: 100, account: Fabricate(:account))
  end

  it "includes all details" do
    json =
      DiscourseKofi::AdminPaymentSerializer.new(
        payment,
        { root: false }
      ).as_json

    expect(json[:id]).to eq payment.id
    expect(json[:payment_type]).to eq "donation"
    expect(json[:amount_currency]).to eq "$100.00"
    expect(json[:message]).to eq payment.message
    expect(json[:username]).to eq payment.user.name
    expect(json[:user_id]).to eq payment.user.id
    expect(json[:kofi_transaction_id]).to eq payment.kofi_transaction_id
    expect(json[:is_public]).to eq payment.is_public
    expect(json[:from_name]).to eq payment.from_name
    expect(json[:email]).to eq payment.email
    expect(json[:is_subscription_payment]).to eq payment.is_subscription_payment
    expect(json[:tier_name]).to eq payment.tier_name

    expect(json[:message_id]).to eq payment.message_id
    expect(json[:url]).to eq payment.url
    expect(
      json[:is_first_subscription_payment]
    ).to eq payment.is_first_subscription_payment
  end
end
