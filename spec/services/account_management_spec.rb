# frozen_string_literal: true

RSpec.describe DiscourseKofi::AccountManagement do
  fab!(:user)
  fab!(:other_user) { Fabricate(:user) }

  fab!(:account) { Fabricate(:account, user: user) }
  fab!(:other_account) { Fabricate(:account, user: other_user) }

  before { @accounts = DiscourseKofi::AccountManagement.new }

  it "finds an existing account" do
    found = @accounts.find_account(account.email)
    expect(found).to eq account
  end

  it "finds nothing on nil" do
    expect(@accounts.find_account(nil)).to be_nil
    expect(@accounts.get_user_account(nil, account.email)).to be_nil
    expect(@accounts.get_user_account(user, nil)).to be_nil
  end

  it "creates an account for an existing user" do
    found = @accounts.find_account(user.email)
    expect(found.previously_new_record?).to be true
  end

  it "returns nil when no account can be found or created" do
    found = @accounts.find_account("unknown@email.example")
    expect(found).to be_nil
  end

  it "finds an existing user account matching email" do
    found = @accounts.get_user_account(user, account.email)
    expect(found).to eq account
  end

  it "finds an existing user account matching email_hash" do
    email = account.email
    account.email = "12345@anonymized.invalid"
    account.save
    found = @accounts.get_user_account(user, email)
    expect(found).to eq account
  end

  it "creates a new account for a user" do
    email = Faker::Internet.email
    found = @accounts.get_user_account(user, email)
    expect(found.previously_new_record?).to be true
    expect(found.email).to eq email
  end

  it "fails when an account exists for a different user" do
    expect {
      @accounts.get_user_account(user, other_account.email)
    }.to raise_error("Account registered to different user")
  end

  it "updates existing payments when creating a new account" do
    email = Faker::Internet.email
    payment1 = Fabricate(:payment, email: email)
    payment2 = Fabricate(:payment, email: email)
    resolved_payment = Fabricate(:payment, account: account)
    resolved_payment.email = email
    resolved_payment.save

    account = @accounts.get_user_account(user, email)
    expect(account.previously_new_record?).to be true

    expect(DiscourseKofi::Payment.find(payment1.id).account).to eq account
    expect(DiscourseKofi::Payment.find(payment2.id).account).to eq account
    expect(
      DiscourseKofi::Payment.find(resolved_payment.id).account
    ).not_to eq account
  end
end
