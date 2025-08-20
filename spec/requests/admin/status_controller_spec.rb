# frozen_string_literal: true

RSpec.describe DiscourseKofi::Admin::StatusController do
  fab!(:admin)

  before do
    SiteSetting.kofi_enabled = true
    sign_in(admin)
  end

  it "has an empty status" do
    get "/ko-fi/admin/status"
    expect(response.status).to eq(200)
    parsed = response.parsed_body
    expect(parsed[:healthy]).to be false
    expect(parsed[:config][:webhook_token_configured]).to be false
    expect(parsed[:success]).to be_nil
    expect(parsed[:error]).to be_nil
  end

  it "has a healthy status" do
    SiteSetting.kofi_webhook_token = "test"
    DiscourseKofi::WebhookStatus.update(success: "test message")

    get "/ko-fi/admin/status"
    expect(response.status).to eq(200)
    parsed = response.parsed_body
    expect(parsed[:healthy]).to be true
    expect(parsed[:config][:webhook_token_configured]).to be true
    expect(parsed[:success][:message]).to eq "test message"
    expect(parsed[:error]).to be_nil
  end

  it "unhealthy because of an error" do
    SiteSetting.kofi_webhook_token = "test"
    DiscourseKofi::WebhookStatus.update(
      success: "test message",
      error: "error message"
    )

    get "/ko-fi/admin/status"
    expect(response.status).to eq(200)
    parsed = response.parsed_body
    expect(parsed[:healthy]).to be false
    expect(parsed[:config][:webhook_token_configured]).to be true
    expect(parsed[:success][:message]).to eq "test message"
    expect(parsed[:error][:message]).to eq "error message"
  end
end
