# frozen_string_literal: true

RSpec.describe DiscourseKofi::AccountSerializer do
  let(:account) { Fabricate(:kofi_account) }

  it "includes default element" do
    json =
      DiscourseKofi::AccountSerializer.new(account, { root: false }).as_json

    expect(json[:id]).to eq account.id
    expect(json[:email]).to eq account.email
    expect(json[:always_hide]).to eq account.always_hide
    expect(json[:user][:id]).to eq account.user.id
  end
end
