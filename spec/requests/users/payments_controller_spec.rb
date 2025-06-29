# frozen_string_literal: true

RSpec.describe DiscourseKofi::Users::PaymentsController do
  before do
    SiteSetting.kofi_enabled = true
    sign_in(account.user)
  end

  fab!(:account)
  fab!(:public_donation) { Fabricate(:payment, amount: 10, account: account) }
  fab!(:private_donation) do
    Fabricate(:payment, amount: 20, is_public: false, account: account)
  end
  fab!(:public_subscription) do
    Fabricate(:subscription, amount: 30, account: account)
  end

  fab!(:other_donation1) { Fabricate(:payment) }
  fab!(:other_account) { Fabricate(:account) }
  fab!(:other_donation2) { Fabricate(:payment, account: other_account) }

  describe "#index" do
    it "returns user all payments" do
      get "/ko-fi/users/payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payments]).to contain_exactly(
        include(id: public_donation.id),
        include(id: private_donation.id),
        include(id: public_subscription.id)
      )
    end
  end

  describe "#show" do
    it "cannot see other donations" do
      get "/ko-fi/users/payments/#{other_donation1.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    it "can update the public flag" do
      patch "/ko-fi/users/payments/#{public_donation.id}",
            params: {
              is_public: false
            }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq "OK"

      get "/ko-fi/users/payments/#{public_donation.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payment][:is_public]).to be false
    end

    it "cannot update other donation" do
      patch "/ko-fi/users/payments/#{other_donation1.id}"
      expect(response.status).to eq(404)
    end
  end

  describe "#claim" do
    it "can claim a payment" do
      post "/ko-fi/users/payments/claim",
           params: {
             reference: other_donation1.kofi_transaction_id
           }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payment][:id]).to eq other_donation1.id

      payment = DiscourseKofi::Payment.find(other_donation1.id)
      # A new account was created
      expect(payment.account.user).to eq account.user
      expect(payment.account.email).to eq other_donation1.email
    end

    it "cannot claim a claimed payment" do
      post "/ko-fi/users/payments/claim",
           params: {
             reference: other_donation2.kofi_transaction_id
           }

      expect(response.status).to eq(400)
      parsed = response.parsed_body
      expect(parsed[:failed]).to eq "already_claimed"
    end

    it "cannot claim a non-existent payment" do
      post "/ko-fi/users/payments/claim",
           params: {
             reference: "does-not-exist"
           }

      expect(response.status).to eq(400)
      parsed = response.parsed_body
      expect(parsed[:failed]).to eq "invalid_reference"
    end
  end
end
