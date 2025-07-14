# frozen_string_literal: true

RSpec.describe DiscourseKofi::PaymentSerializer do
  let(:account) { Fabricate(:kofi_account) }
  let(:payment) { Fabricate(:kofi_payment, amount: 100) }

  it "includes configured elements" do
    json =
      DiscourseKofi::PaymentSerializer.new(
        payment,
        { root: false, visible_details: %w[amount message] }
      ).as_json

    expect(json[:id]).to eq payment.id
    expect(json[:payment_type]).to eq "donation"
    expect(json[:amount_currency]).to eq "$100.00"
    expect(json[:message]).to eq payment.message
    expect(json[:username]).to be_nil
  end

  it "excludes non-public" do
    payment.is_public = false
    json =
      DiscourseKofi::PaymentSerializer.new(
        payment,
        { root: false, visible_details: %w[amount message] }
      ).as_json

    expect(json[:payment_type]).to eq "donation"
    expect(json[:amount_currency]).to eq "$100.00"
    expect(json[:message]).to be_nil
    expect(json[:username]).to be_nil
  end

  it "uses from name for unresolved payments" do
    json =
      DiscourseKofi::PaymentSerializer.new(
        payment,
        { root: false, visible_details: %w[user] }
      ).as_json

    expect(json[:username]).to eq payment.from_name
  end

  it "uses user name for resolved payments" do
    payment.account = account
    json =
      DiscourseKofi::PaymentSerializer.new(
        payment,
        { root: false, visible_details: %w[user] }
      ).as_json

    expect(json[:username]).to eq account.user.name
    expect(json[:user_id]).to eq account.user.id
  end
end
