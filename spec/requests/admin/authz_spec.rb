# frozen_string_literal: true

RSpec.describe "admin controller authz" do
  before { SiteSetting.kofi_enabled = true }

  describe "payments" do
    fab!(:payment)

    it "#index" do
      get "/ko-fi/admin/payments"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/payments/#{payment.id}"
      expect(response.status).to eq(404)
    end

    it "#update" do
      patch "/ko-fi/admin/payments/#{payment.id}"
      expect(response.status).to eq(404)
    end

    it "#import" do
      post "/ko-fi/admin/import/#{payment.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "rewards" do
    fab!(:reward)

    it "#index" do
      get "/ko-fi/admin/rewards"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/rewards/#{reward.id}"
      expect(response.status).to eq(404)
    end

    it "#update" do
      post "/ko-fi/admin/rewards/#{reward.id}"
      expect(response.status).to eq(404)
    end

    it "#destroy" do
      delete "/ko-fi/admin/rewards/#{reward.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "accounts" do
    fab!(:account)

    it "#index" do
      get "/ko-fi/admin/accounts"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/accounts/#{account.id}"
      expect(response.status).to eq(404)
    end

    it "#destroy" do
      delete "/ko-fi/admin/accounts/#{account.id}"
      expect(response.status).to eq(404)
    end

    it "#anonymize" do
      post "/ko-fi/admin/accounts/anonymize"
      expect(response.status).to eq(404)
    end
  end
end
