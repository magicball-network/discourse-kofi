# frozen_string_literal: true

RSpec.describe DiscourseKofi::AccountSerializer do
  fab!(:account) { Fabricate(:kofi_account) }
  fab!(:payment) { Fabricate(:kofi_payment, account: account) }

  it "includes default elements" do
    json =
      DiscourseKofi::AccountSerializer.new(
        DiscourseKofi::Account.find(account.id),
        { root: false }
      ).as_json

    expect(json[:id]).to eq account.id
    expect(json[:email]).to eq account.email
    expect(json[:always_hide]).to eq account.always_hide
    expect(json[:user][:id]).to eq account.user.id
    expect(json[:latest_payment][:id]).to eq payment.id
  end
end
