# frozen_string_literal: true

RSpec.describe DiscourseKofi::Admin::AccountsController do
  fab!(:admin)

  before do
    SiteSetting.kofi_enabled = true
    sign_in(admin)
  end

  fab!(:account1) { Fabricate(:kofi_account) }
  fab!(:account2) { Fabricate(:kofi_account, user: account1.user) }
  fab!(:account3) { Fabricate(:kofi_account) }

  describe "#index" do
    it "lists all accounts" do
      get "/ko-fi/admin/accounts"

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:accounts]).to contain_exactly(
        include(
          id: account1.id,
          anonymized: false,
          email_hash: account1.email_hash
        ),
        include(
          id: account2.id,
          anonymized: false,
          email_hash: account2.email_hash
        ),
        include(
          id: account3.id,
          anonymized: false,
          email_hash: account3.email_hash
        )
      )
    end

    it "filters on email" do
      get "/ko-fi/admin/accounts", params: { search: account1.email[3, 10] }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:accounts]).to contain_exactly(include(id: account1.id))
    end

    it "filters on username" do
      get "/ko-fi/admin/accounts",
          params: {
            search: account1.user.username[1, 6].upcase
          }

      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:accounts]).to contain_exactly(
        include(id: account1.id),
        include(id: account2.id)
      )
    end
  end

  describe "#show" do
    it "retrieves a single account" do
      get "/ko-fi/admin/accounts/#{account1.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:account][:email_hash]).to eq(account1.email_hash)
    end

    it "returns a 404 on a non existing account" do
      get "/ko-fi/admin/accounts/999999999999"
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    it "updates hide_always" do
      StaffActionLogger
        .any_instance
        .expects(:log_custom)
        .with(
          "kofi_account_change",
          { always_hide: true, account_id: account1.id }
        )
        .once

      patch "/ko-fi/admin/accounts/#{account1.id}",
            params: {
              always_hide: true
            }
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq("OK")

      get "/ko-fi/admin/accounts/#{account1.id}"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:account][:always_hide]).to be(true)
    end

    it "cannot update an unknown account" do
      StaffActionLogger.any_instance.expects(:log_custom).never

      patch "/ko-fi/admin/accounts/999999999999", params: { always_hide: true }
      expect(response.status).to eq(404)
    end
  end

  describe "#privatize_payments" do
    fab!(:payment1) { Fabricate(:kofi_payment, account: account1) }
    fab!(:payment2) { Fabricate(:kofi_payment, account: account2) }

    it "privatized existing payments" do
      StaffActionLogger
        .any_instance
        .expects(:log_custom)
        .with("kofi_payment_privatized", { account_id: account1.id })
        .once

      post "/ko-fi/admin/accounts/#{account1.id}/privatize-payments"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq("OK")

      reloaded_payment = DiscourseKofi::Payment.find(payment1.id)
      expect(reloaded_payment.is_public).to be(false)
      reloaded_payment = DiscourseKofi::Payment.find(payment2.id)
      expect(reloaded_payment.is_public).to be(true)
    end

    it "does nothing for an unknown account" do
      StaffActionLogger.any_instance.expects(:log_custom).never

      post "/ko-fi/admin/accounts/999999999999/privatize-payments"
      expect(response.status).to eq(404)

      reloaded_payment = DiscourseKofi::Payment.find(payment1.id)
      expect(reloaded_payment.is_public).to be(true)
      reloaded_payment = DiscourseKofi::Payment.find(payment2.id)
      expect(reloaded_payment.is_public).to be(true)
    end
  end

  describe "#anonymize" do
    it "anonymizes an account" do
      allow(DiscourseKofi::Anonymizer).to receive(:anonymize_account)
      StaffActionLogger
        .any_instance
        .expects(:log_custom)
        .with("kofi_account_anonymized", { account_id: account1.id })
        .once

      post "/ko-fi/admin/accounts/#{account1.id}/anonymize"
      expect(response.status).to eq(200)
      parsed = response.parsed_body
      expect(parsed[:success]).to eq("OK")

      expect(DiscourseKofi::Anonymizer).to have_received(
        :anonymize_account
      ).with(eq(account1)).once
    end

    it "does nothing for an unknown account" do
      allow(DiscourseKofi::Anonymizer).to receive(:anonymize_account)
      StaffActionLogger.any_instance.expects(:log_custom).never

      post "/ko-fi/admin/accounts/999999999999/anonymize"
      expect(response.status).to eq(404)

      expect(DiscourseKofi::Anonymizer).to_not have_received(:anonymize_account)
    end
  end

  describe "#destroy" do
    it "unlinks payment on account destroy" do
      payment = Fabricate(:kofi_payment, account: account1)
      payment.save

      delete "/ko-fi/admin/accounts/#{account1.id}"
      expect(response.status).to eq(200)

      get "/ko-fi/admin/accounts/#{account1.id}"
      expect(response.status).to eq(404)

      reloaded_payment = DiscourseKofi::Payment.find(payment.id)
      expect(reloaded_payment.account).to be_nil
      expect(reloaded_payment.user).to be_nil
    end

    it "cannot destroy an unknown account" do
      delete "/ko-fi/admin/accounts/999999999999"
      expect(response.status).to eq(404)
    end
  end
end
