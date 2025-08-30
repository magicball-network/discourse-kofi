# frozen_string_literal: true

RSpec.describe DiscourseKofi::AccountQueryBuilder do
  fab!(:account1) { Fabricate(:kofi_account) }
  fab!(:payment1) do
    Fabricate(
      :kofi_payment,
      account: account1,
      timestamp: DateTime.iso8601("2025-06-01T00:00:00")
    )
  end
  fab!(:payment2) do
    Fabricate(
      :kofi_payment,
      account: account1,
      timestamp: DateTime.iso8601("2025-06-02T00:00:00")
    )
  end

  fab!(:account2) { Fabricate(:kofi_account, user: account1.user) }
  fab!(:account3) { Fabricate(:kofi_account) }
  fab!(:account4) { Fabricate(:kofi_account) }

  it "returns all accounts" do
    account = DiscourseKofi::AccountQueryBuilder.new({})
    accounts = account.find_accounts()

    expect(accounts).to eq([account4, account3, account2, account1])
  end

  it "has a pre-filter" do
    account =
      DiscourseKofi::AccountQueryBuilder.new({}, { user: account1.user })
    accounts = account.find_accounts()

    expect(accounts).to eq([account2, account1])

    account =
      DiscourseKofi::AccountQueryBuilder.new(
        { search: account2.email },
        { user: account1.user }
      )
    accounts = account.find_accounts()

    expect(accounts).to eq([account2])
  end

  it "does pagination" do
    account = DiscourseKofi::AccountQueryBuilder.new({ page: 1 })
    accounts = account.find_accounts(2)

    expect(accounts).to eq([account4, account3])
  end

  it "does ordering" do
    account =
      DiscourseKofi::AccountQueryBuilder.new({ order: "created_at", asc: true })
    accounts = account.find_accounts()
    expect(accounts).to eq([account1, account2, account3, account4])

    account = DiscourseKofi::AccountQueryBuilder.new({ order: "created_at" })
    accounts = account.find_accounts()

    expect(accounts).to eq([account4, account3, account2, account1])
  end

  it "searches part of the from name" do
    account =
      DiscourseKofi::AccountQueryBuilder.new(
        { search: account4.user.username[1..-1] }
      )
    accounts = account.find_accounts()
    expect(accounts).to eq([account4])
  end

  it "searches part of the email" do
    account =
      DiscourseKofi::AccountQueryBuilder.new({ search: account3.email[3..-3] })
    accounts = account.find_accounts()
    expect(accounts).to eq([account3])
  end

  it "searches part of the user's name" do
    account =
      DiscourseKofi::AccountQueryBuilder.new(
        { search: account1.user.username[2..] }
      )
    accounts = account.find_accounts()
    expect(accounts).to eq([account2, account1])
  end
end
