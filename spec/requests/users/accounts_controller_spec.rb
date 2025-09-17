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

  describe "#privatize_payments" do
    fab!(:payment1) { Fabricate(:kofi_payment, account: kofi_account) }
    fab!(:payment2) { Fabricate(:kofi_payment, account: other_account) }

    it "privatized existing payments" do
      post "/ko-fi/users/accounts/#{kofi_account.id}/privatize-payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq("OK")

      reloaded_payment = DiscourseKofi::Payment.find(payment1.id)
      expect(reloaded_payment.is_public).to be(false)
      reloaded_payment = DiscourseKofi::Payment.find(payment2.id)
      expect(reloaded_payment.is_public).to be(true)
    end

    it "cannot privatize other accounts" do
      post "/ko-fi/users/accounts/#{other_account.id}/privatize-payments"
      expect(response.status).to eq(404)
    end
  end
end
