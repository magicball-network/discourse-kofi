# frozen_string_literal: true

RSpec.describe DiscourseKofi::PaymentImporter do
  it "can import payments from a CSV" do
    result =
      DiscourseKofi::PaymentImporter.import_csv(
        plugin_file_fixture("import.csv")
      )

    expect(result[:invalid_rows]).to match_array([])

    payments = DiscourseKofi::Payment.find(result[:payments])
    expect(payments).to contain_exactly(
      have_attributes(
        from_name: "user1",
        message: "donation message 1",
        is_subscription_payment: false
      ),
      have_attributes(
        from_name: "user2",
        message: "donation message 2",
        is_subscription_payment: false
      ),
      have_attributes(
        from_name: "user3",
        is_subscription_payment: true,
        is_first_subscription_payment: true,
        tier_name: "Premium"
      ),
      have_attributes(
        from_name: "user3",
        is_subscription_payment: true,
        is_first_subscription_payment: false,
        tier_name: "Premium"
      )
    )
  end

  it "excludes invalid rows" do
    payment = Fabricate(:payment)
    payment.kofi_transaction_id = "55555555-1111-2222-3333-444444444444"
    payment.save

    result =
      DiscourseKofi::PaymentImporter.import_csv(
        plugin_file_fixture("import_invalid_entries.csv")
      )

    expect(result[:invalid_rows]).to contain_exactly(
      include(line_number: 2, message: include("UnknownTransactionType")),
      include(line_number: 3, message: include("InvalidDateTime")),
      include(line_number: 4, message: include("InvalidAmount")),
      include(line_number: 5, message: "Zero or negative amount"),
      include(
        line_number: 6,
        message: "Subscription payment requires an item value as tier name"
      ),
      include(line_number: 7, message: "Test transaction ID"),
      include(line_number: 8, message: "Transaction already registered")
    )
  end
end
