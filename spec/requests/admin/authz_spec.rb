# frozen_string_literal: true

RSpec.describe "admin controller authz" do
  before { SiteSetting.kofi_enabled = true }

  describe "payments" do
    fab!(:kofi_payment)

    it "#index" do
      get "/ko-fi/admin/payments"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/payments/#{kofi_payment.id}"
      expect(response.status).to eq(404)
    end

    it "#update" do
      patch "/ko-fi/admin/payments/#{kofi_payment.id}"
      expect(response.status).to eq(404)
    end

    it "#import" do
      post "/ko-fi/admin/payments/import"
      expect(response.status).to eq(404)
    end

    it "#anonymize" do
      post "/ko-fi/admin/payments/anonymize"
      expect(response.status).to eq(404)
    end
  end

  describe "rewards" do
    fab!(:kofi_reward)

    it "#index" do
      get "/ko-fi/admin/rewards"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/rewards/#{kofi_reward.id}"
      expect(response.status).to eq(404)
    end

    it "#update" do
      post "/ko-fi/admin/rewards/#{kofi_reward.id}"
      expect(response.status).to eq(404)
    end

    it "#destroy" do
      delete "/ko-fi/admin/rewards/#{kofi_reward.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "accounts" do
    fab!(:kofi_account)

    it "#index" do
      get "/ko-fi/admin/accounts"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/accounts/#{kofi_account.id}"
      expect(response.status).to eq(404)
    end

    it "#update" do
      patch "/ko-fi/admin/accounts/#{kofi_account.id}"
      expect(response.status).to eq(404)
    end

    it "#update" do
      patch "/ko-fi/admin/accounts/#{kofi_account.id}"
      expect(response.status).to eq(404)
    end

    it "#privatize_payments" do
      post "/ko-fi/admin/accounts/#{kofi_account.id}/privatize-payments"
      expect(response.status).to eq(404)
    end

    it "#anonymize" do
      post "/ko-fi/admin/accounts/#{kofi_account.id}/anonymize"
      expect(response.status).to eq(404)
    end

    it "#destroy" do
      delete "/ko-fi/admin/accounts/#{kofi_account.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "status" do
    it "#index" do
      get "/ko-fi/admin/status"
      expect(response.status).to eq(404)
    end
  end
end
