# frozen_string_literal: true

RSpec.describe "users controller authz" do
  before { SiteSetting.kofi_enabled = true }

  describe "payments" do
    fab!(:kofi_payment)

    it "#index" do
      get "/ko-fi/users/payments"
      expect(response.status).to eq(403)
    end

    it "#show" do
      get "/ko-fi/users/payments/#{kofi_payment.id}"
      expect(response.status).to eq(403)
    end

    it "#update" do
      patch "/ko-fi/users/payments/#{kofi_payment.id}"
      expect(response.status).to eq(403)
    end
  end

  describe "accounts" do
    fab!(:kofi_account)

    it "#index" do
      get "/ko-fi/users/accounts"
      expect(response.status).to eq(403)
    end

    it "#show" do
      get "/ko-fi/users/accounts/#{kofi_account.id}"
      expect(response.status).to eq(403)
    end

    it "#update" do
      patch "/ko-fi/users/accounts/#{kofi_account.id}"
      expect(response.status).to eq(403)
    end

    it "#privatize_payments" do
      post "/ko-fi/users/accounts/#{kofi_account.id}/privatize-payments"
      expect(response.status).to eq(403)
    end
  end
end
