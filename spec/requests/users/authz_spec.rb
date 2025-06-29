# frozen_string_literal: true

RSpec.describe "users controller authz" do
  before { SiteSetting.kofi_enabled = true }

  describe "payments" do
    fab!(:payment)

    it "#index" do
      get "/ko-fi/users/payments.json"
      expect(response.status).to eq(403)
    end

    it "#show" do
      get "/ko-fi/users/payments/#{payment.id}.json"
      expect(response.status).to eq(403)
    end

    it "#update" do
      patch "/ko-fi/users/payments/#{payment.id}.json"
      expect(response.status).to eq(403)
    end
  end

  describe "accounts" do
    fab!(:account)

    it "#index" do
      get "/ko-fi/users/accounts.json"
      expect(response.status).to eq(403)
    end

    it "#show" do
      get "/ko-fi/users/accounts/#{account.id}.json"
      expect(response.status).to eq(403)
    end

    it "#update" do
      patch "/ko-fi/users/accounts/#{account.id}.json"
      expect(response.status).to eq(403)
    end
  end
end
