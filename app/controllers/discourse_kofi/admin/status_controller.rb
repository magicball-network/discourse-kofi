# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class StatusController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        status = WebhookStatus.get
        status["config"] = {
          webhook_token_configured: SiteSetting.kofi_webhook_token.present?
        }
        status["healthy"] = SiteSetting.kofi_webhook_token.present? &&
          status["success"].present? && status["error"].nil?
        render json: status
      end
    end
  end
end
