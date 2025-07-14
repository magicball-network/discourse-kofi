# frozen_string_literal: true

RSpec.describe DiscourseKofi::Users::AccountsController do
  before do
    SiteSetting.kofi_enabled = true
    sign_in(kofi_account.user)
  end

  fab!(:kofi_account)
  fab!(:other_account) { Fabricate(:kofi_account) }

  describe "#index" do
    it "returns user all accounts" do
      get "/ko-fi/users/accounts"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:accounts]).to contain_exactly(include(id: kofi_account.id))
    end
  end

  describe "#show" do
    it "cannot see other donations" do
      get "/ko-fi/users/accounts/#{other_account.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    it "can update the always_hide flag" do
      patch "/ko-fi/users/accounts/#{kofi_account.id}",
            params: {
              always_hide: true
            }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq "OK"

      get "/ko-fi/users/accounts/#{kofi_account.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:account][:always_hide]).to be true
    end

    it "cannot update other accounts" do
      patch "/ko-fi/users/accounts/#{other_account.id}"
      expect(response.status).to eq(404)
    end
  end
end
