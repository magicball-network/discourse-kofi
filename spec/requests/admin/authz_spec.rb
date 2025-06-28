# frozen_string_literal: true

RSpec.describe "admin controller authz" do
  before { SiteSetting.kofi_enabled = true }

  describe "payments" do
    fab!(:payment)

    it "#index" do
      get "/ko-fi/admin/payments.json"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/payments/#{payment.id}.json"
      expect(response.status).to eq(404)
    end

    it "#update" do
      patch "/ko-fi/admin/payments/#{payment.id}.json"
      expect(response.status).to eq(404)
    end
  end

  describe "rewards" do
    fab!(:reward)

    it "#index" do
      get "/ko-fi/admin/rewards.json"
      expect(response.status).to eq(404)
    end

    it "#show" do
      get "/ko-fi/admin/rewards/#{reward.id}.json"
      expect(response.status).to eq(404)
    end

    it "#update" do
      post "/ko-fi/admin/rewards/#{reward.id}.json"
      expect(response.status).to eq(404)
    end

    it "#destroy" do
      delete "/ko-fi/admin/rewards/#{reward.id}.json"
      expect(response.status).to eq(404)
    end
  end
end
