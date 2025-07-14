# frozen_string_literal: true

RSpec.describe DiscourseKofi::AdminAccountSerializer do
  let(:account) { Fabricate(:kofi_account) }

  it "includes default element" do
    json =
      DiscourseKofi::AdminAccountSerializer.new(
        account,
        { root: false }
      ).as_json

    expect(json[:id]).to eq account.id
    expect(json[:email]).to eq account.email
    expect(json[:always_hide]).to eq account.always_hide
    expect(json[:user][:id]).to eq account.user.id
    expect(json[:anonymized]).to eq account.anonymized
    expect(json[:email_hash]).to eq account.email_hash
  end
end
