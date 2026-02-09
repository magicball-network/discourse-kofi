# frozen_string_literal: true

RSpec.describe DiscourseKofi::PaymentQueryBuilder do
  fab!(:account, :kofi_account)
  fab!(:payment1) do
    Fabricate(
      :kofi_payment,
      amount: 10,
      account: account,
      timestamp: DateTime.iso8601("2025-06-01T00:00:00")
    )
  end
  fab!(:payment2) do
    Fabricate(
      :kofi_payment,
      amount: 90,
      account: account,
      timestamp: DateTime.iso8601("2025-06-02T00:00:00")
    )
  end
  fab!(:payment3) do
    Fabricate(
      :kofi_payment,
      amount: 50,
      timestamp: DateTime.iso8601("2025-06-03T00:00:00")
    )
  end
  fab!(:payment4) do
    Fabricate(
      :kofi_payment,
      amount: 30,
      timestamp: DateTime.iso8601("2025-06-04T00:00:00")
    )
  end
  fab!(:payment5) do
    Fabricate(
      :kofi_payment,
      amount: 70,
      timestamp: DateTime.iso8601("2025-06-05T00:00:00")
    )
  end

  it "returns all payments" do
    payment = DiscourseKofi::PaymentQueryBuilder.new({})
    payments = payment.find_payments()

    expect(payments).to eq([payment5, payment4, payment3, payment2, payment1])
  end

  it "has a pre-filter" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new({}, { user: payment1.user })
    payments = payment.find_payments()

    expect(payments).to eq([payment2, payment1])

    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { search: payment2.from_name },
        { user: payment1.user }
      )
    payments = payment.find_payments()

    expect(payments).to eq([payment2])
  end

  it "does pagination" do
    payment = DiscourseKofi::PaymentQueryBuilder.new({ page: 1 })
    payments = payment.find_payments(2)

    expect(payments).to eq([payment5, payment4])
  end

  it "does ordering" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new({ order: "timestamp", asc: true })
    payments = payment.find_payments()
    expect(payments).to eq([payment1, payment2, payment3, payment4, payment5])

    payment = DiscourseKofi::PaymentQueryBuilder.new({ order: "timestamp" })
    payments = payment.find_payments()

    expect(payments).to eq([payment5, payment4, payment3, payment2, payment1])
  end

  it "orders on amount" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new({ order: "amount", asc: true })
    payments = payment.find_payments()
    expect(payments).to eq([payment1, payment4, payment3, payment5, payment2])
  end

  it "searches on transaction id" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { search: payment5.kofi_transaction_id }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment5])
  end

  it "searches part of the from name" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { search: payment4.from_name[3..-3] }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment4])
  end

  it "searches part of the email" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new({ search: payment3.email[3..-3] })
    payments = payment.find_payments()
    expect(payments).to eq([payment3])
  end

  it "searches part of the user's name" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { search: account.user.username[2..] }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment2, payment1])
  end

  it "limits to a period" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { startDate: "2025-06-02T23:00:00", endDate: "2025-06-03T01:00:00" }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment3])
  end

  it "limits to a period with no end" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { startDate: "2025-06-03T13:00:00" }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment5, payment4])
  end

  it "can search for a specific transaction" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { search: "tx:#{payment1.kofi_transaction_id}" }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment1])
  end

  it "can search for a specific account" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new({ search: "aid:#{account.id}" })
    payments = payment.find_payments()
    expect(payments).to eq([payment2, payment1])
  end

  it "can search for a specific user" do
    payment =
      DiscourseKofi::PaymentQueryBuilder.new(
        { search: "uid:#{account.user.id}" }
      )
    payments = payment.find_payments()
    expect(payments).to eq([payment2, payment1])
  end
end
