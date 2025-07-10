# frozen_string_literal: true

RSpec.describe DiscourseKofi::Admin::PaymentsController do
  fab!(:admin)

  before do
    SiteSetting.kofi_enabled = true
    sign_in(admin)
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
    it "returns all payments" do
      get "/ko-fi/admin/payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payments]).to contain_exactly(
        include(id: public_donation.id),
        include(id: private_donation.id),
        include(id: public_subscription.id),
        include(id: other_donation1.id),
        include(id: other_donation2.id)
      )
    end
  end

  describe "#update" do
    it "can update the public flag" do
      patch "/ko-fi/admin/payments/#{public_donation.id}",
            params: {
              is_public: false
            }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq "OK"

      get "/ko-fi/admin/payments/#{public_donation.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:payment][:is_public]).to be false
    end
  end

  describe "#import" do
    it "can import a payments CSV file" do
      file = plugin_file_fixture("import.csv")
      post "/ko-fi/admin/payments/import",
           params: {
             make_private: "true",
             file: fixture_file_upload(file)
           }

      expect(response.status).to eq(200)
      expect(response.parsed_body["invalid_rows"]).to match_array([])
      payments = response.parsed_body["payments"]
      expect(payments.length).to eq(4)
      expect(DiscourseKofi::Payment.find(payments).length).to eq(4)
    end

    it "fails importing a broken csv file" do
      file = plugin_file_fixture("invalid.csv")
      post "/ko-fi/admin/payments/import",
           params: {
             file: fixture_file_upload(file)
           }

      expect(response.status).to eq(400)
      expect(response.parsed_body["errors"]).to match_array(
        include(I18n.t("kofi.payments.import.invalid_csv", error: ""))
      )
    end
  end

  describe "#anonymize" do
    it "creates an anonymized account" do
      payment = Fabricate(:payment)

      post "/ko-fi/admin/payments/anonymize", params: { email: payment.email }
      expect(response.status).to eq(200)

      reloaded_payment = DiscourseKofi::Payment.find(payment.id)
      expect(reloaded_payment.account).not_to be_nil
      expect(reloaded_payment.account.email).not_to eq(payment.email)
      expect(reloaded_payment.user).to be_nil
      expect(reloaded_payment.account.anonymized).to be true
      expect(reloaded_payment.anonymized).to be true
      expect(reloaded_payment.from_name).to eq ""
      expect(reloaded_payment.message).to eq ""
      expect(reloaded_payment.is_public).to be false
      expect(reloaded_payment.email).not_to eq(payment.email)
    end
  end
end
