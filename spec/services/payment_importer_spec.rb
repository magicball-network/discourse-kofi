# frozen_string_literal: true

require "date"

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
        timestamp: DateTime.iso8601("2025-01-13T12:56"),
        from_name: "user1",
        message: "donation message 1",
        email: "user1@discourse-kofi.test",
        kofi_transaction_id: "7e037596-b595-4ab7-bd05-3a4308e834ec",
        is_public: false,
        is_subscription_payment: false
      ),
      have_attributes(
        timestamp: DateTime.iso8601("2025-02-14T17:27"),
        from_name: "user2",
        message: "donation message 2",
        email: "usertwo@discourse-kofi.test",
        kofi_transaction_id: "9fbc84a7-9fa7-4882-b429-85e85a3e7fc9",
        is_public: false,
        is_subscription_payment: false
      ),
      have_attributes(
        timestamp: DateTime.iso8601("2025-03-15T18:30"),
        from_name: "user3",
        kofi_transaction_id: "4f041adf-ff2d-4b6b-9969-39fbe9f34082",
        is_public: false,
        is_subscription_payment: true,
        is_first_subscription_payment: true,
        tier_name: "Premium"
      ),
      have_attributes(
        timestamp: DateTime.iso8601("2025-04-15T18:30"),
        from_name: "user3",
        kofi_transaction_id: "d431af97-60d0-4014-9433-6801685f34e4",
        is_public: false,
        is_subscription_payment: true,
        is_first_subscription_payment: false,
        tier_name: "Premium"
      )
    )
  end

  it "excludes invalid rows" do
    payment = Fabricate(:kofi_payment)
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
