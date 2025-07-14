# frozen_string_literal: true

RSpec.describe DiscourseKofi::Account, type: :model do
  it "computes the email hash once" do
    account = Fabricate(:kofi_account)
    account.save

    hash_value = account.email_hash
    account.email = Faker::Internet.email
    account.save

    expect(account.email_hash).to eq hash_value
  end

  it "is not possible to set the email_hash" do
    account = Fabricate(:kofi_account)
    expect { account.email_hash = "foo " }.to raise_error(
      ActiveRecord::ReadonlyAttributeError
    )
  end

  it "anonymized an account" do
    account = Fabricate(:kofi_account)
    account.make_anonymous("12345@anonymous.invalid")

    expect(account.anonymized).to be true
    expect(account.email).to eq "12345@anonymous.invalid"
    expect(account.always_hide).to be true
  end
end
