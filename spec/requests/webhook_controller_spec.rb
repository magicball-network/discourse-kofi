# frozen_string_literal: true

RSpec.describe DiscourseKofi::WebhookController do
  before do
    SiteSetting.kofi_enabled = true
    SiteSetting.kofi_webhook_token = "webhook-token"
  end

  def gen_kofi_webhook_message(
    message_id: SecureRandom.uuid,
    kofi_transaction_id: SecureRandom.uuid
  )
    json = plugin_file_fixture("webhook.json").read
    hash = ActiveSupport::JSON.decode(json)
    hash["message_id"] = message_id
    hash["kofi_transaction_id"] = kofi_transaction_id
    hash["verification_token"] = SiteSetting.kofi_webhook_token
    hash
  end

  let(:webhook_message) { gen_kofi_webhook_message }

  it "rejects when no data is provided" do
    post "/ko-fi/webhook"
    expect(response.status).to eq(400)
  end

  it "rejects invalid data" do
    post "/ko-fi/webhook", params: { data: "this is not valid JSON!" }
    expect(response.status).to eq(400)
  end

  it "rejects an incorrect token" do
    allow(DiscourseKofi::WebhookStatus).to receive(:update)
    allow(I18n).to receive(:t)

    post "/ko-fi/webhook",
         params: {
           data: { verification_token: "invalid" }.to_json
         }
    expect(response.status).to eq(403)

    expect(DiscourseKofi::WebhookStatus).to have_received(:update).with(
      have_key(:error)
    )
    expect(I18n).to have_received(:t).with(
      "kofi.webhook.status.invalid_token",
      any_args
    )
  end

  it "accepts a test transaction" do
    allow(DiscourseKofi::WebhookStatus).to receive(:update)
    allow(I18n).to receive(:t)

    post "/ko-fi/webhook",
         params: {
           data: {
             message_id: SecureRandom.uuid,
             kofi_transaction_id: DiscourseKofi::Payment::TEST_TRANSACTION_ID,
             verification_token: SiteSetting.kofi_webhook_token
           }.to_json
         }
    expect(response.status).to eq(200)

    expect(DiscourseKofi::WebhookStatus).to have_received(:update).with(
      have_key(:success)
    )
    expect(I18n).to have_received(:t).with(
      "kofi.webhook.status.test_transaction",
      any_args
    )

    payment_count =
      DiscourseKofi::Payment.where(
        kofi_transaction_id: DiscourseKofi::Payment::TEST_TRANSACTION_ID
      ).count
    expect(payment_count).to eq(0)
  end

  it "processes a message" do
    allow(DiscourseKofi::WebhookStatus).to receive(:update)
    allow(I18n).to receive(:t)

    post "/ko-fi/webhook", params: { data: webhook_message.to_json }

    expect(response.status).to eq(200)

    payment_count =
      DiscourseKofi::Payment.where(
        kofi_transaction_id: webhook_message["kofi_transaction_id"]
      ).count
    expect(payment_count).to eq(1)

    expect(DiscourseKofi::WebhookStatus).to have_received(:update).with(
      have_key(:success)
    )
    expect(I18n).to have_received(:t).with(
      "kofi.webhook.status.message_received",
      any_args
    )
  end

  it "rejects an already received message" do
    post "/ko-fi/webhook", params: { data: webhook_message.to_json }
    expect(response.status).to eq(200)

    allow(DiscourseKofi::WebhookStatus).to receive(:update)
    allow(I18n).to receive(:t)

    post "/ko-fi/webhook",
         params: {
           data:
             gen_kofi_webhook_message(
               message_id: webhook_message["message_id"]
             ).to_json
         }
    expect(response.status).to eq(200)

    expect(DiscourseKofi::WebhookStatus).to have_received(:update).with(
      have_key(:success)
    )
    expect(I18n).to have_received(:t).with(
      "kofi.webhook.status.duplicate_message",
      any_args
    )
  end

  it "rejects a known transaction" do
    post "/ko-fi/webhook", params: { data: webhook_message.to_json }
    expect(response.status).to eq(200)

    allow(DiscourseKofi::WebhookStatus).to receive(:update)
    allow(I18n).to receive(:t)

    post "/ko-fi/webhook",
         params: {
           data:
             gen_kofi_webhook_message(
               kofi_transaction_id: webhook_message["kofi_transaction_id"]
             ).to_json
         }
    expect(response.status).to eq(200)

    expect(DiscourseKofi::WebhookStatus).to have_received(:update).with(
      have_key(:success)
    )
    expect(I18n).to have_received(:t).with(
      "kofi.webhook.status.known_transaction",
      any_args
    )
  end

  it "rejects an invalid payment message" do
    allow(DiscourseKofi::WebhookStatus).to receive(:update)
    allow(I18n).to receive(:t)

    webhook_message["is_subscription_payment"] = false
    webhook_message["tier_name"] = "this isn't a subscription message"
    post "/ko-fi/webhook", params: { data: webhook_message.to_json }

    expect(response.status).to eq(400)

    expect(DiscourseKofi::WebhookStatus).to have_received(:update).with(
      have_key(:error)
    )
    expect(I18n).to have_received(:t).with(
      "kofi.webhook.status.save_error",
      any_args
    )
  end
end
