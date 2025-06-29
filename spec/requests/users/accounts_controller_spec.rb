# frozen_string_literal: true

RSpec.describe DiscourseKofi::Users::AccountsController do
  before do
    SiteSetting.kofi_enabled = true
    sign_in(account.user)
  end

  fab!(:account)
  fab!(:other_account) { Fabricate(:account) }

  describe "#index" do
    it "returns user all accounts" do
      get "/ko-fi/users/accounts.json"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:accounts]).to contain_exactly(include(id: account.id))
    end
  end

  describe "#show" do
    it "cannot see other donations" do
      get "/ko-fi/users/accounts/#{other_account.id}.json"
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    it "can update the always_hide flag" do
      patch "/ko-fi/users/accounts/#{account.id}.json",
            params: {
              always_hide: true
            }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq "OK"

      get "/ko-fi/users/accounts/#{account.id}.json"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:account][:always_hide]).to be true
    end

    it "cannot update other accounts" do
      patch "/ko-fi/users/accounts/#{other_account.id}.json"
      expect(response.status).to eq(404)
    end
  end
end
