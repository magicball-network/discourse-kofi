# frozen_string_literal: true

RSpec.describe DiscourseKofi::PaymentsController do
  before do
    SiteSetting.kofi_enabled = true
    SiteSetting.kofi_dashboard_enabled = "enabled"
  end

  describe "#index" do
    fab!(:kofi_account)
    fab!(:public_donation) { Fabricate(:kofi_payment, amount: 10) }
    fab!(:resolved_donation) do
      Fabricate(:kofi_payment, amount: 15, account: kofi_account)
    end
    fab!(:private_donation) do
      Fabricate(:kofi_payment, amount: 20, is_public: false)
    end
    fab!(:public_subscription) { Fabricate(:kofi_subscription, amount: 30) }

    it "returns an empty result when disabled" do
      SiteSetting.kofi_dashboard_enabled = "disabled"
      get "/ko-fi/payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payments]).to be_empty
    end

    it "returns an empty result when anonymous" do
      SiteSetting.kofi_dashboard_enabled = "authenticated_only"
      get "/ko-fi/payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payments]).to be_empty
    end

    it "returns anonymous data" do
      get "/ko-fi/payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payments]).to contain_exactly(
        include(
          id: public_donation.id,
          amount_currency: "$10.00",
          message: nil,
          username: nil
        ),
        include(
          id: resolved_donation.id,
          amount_currency: "$15.00",
          message: nil,
          username: nil
        ),
        include(
          id: private_donation.id,
          amount_currency: "$20.00",
          message: nil,
          username: nil
        )
      )
    end

    it "returns authenticated data" do
      sign_in(kofi_account.user)

      get "/ko-fi/payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payments]).to contain_exactly(
        include(
          id: public_donation.id,
          amount_currency: "$10.00",
          message: public_donation.message,
          username: public_donation.from_name
        ),
        include(
          id: resolved_donation.id,
          amount_currency: "$15.00",
          message: resolved_donation.message,
          username: resolved_donation.user.username,
          user: include(id: resolved_donation.user.id)
        ),
        include(
          id: private_donation.id,
          amount_currency: "$20.00",
          message: nil,
          username: nil
        )
      )
    end
  end
end
