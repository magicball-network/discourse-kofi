# frozen_string_literal: true

module ::DiscourseKofi
  class WebhookController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    layout false

    skip_before_action :check_xhr,
                       :redirect_to_login_if_required,
                       :redirect_to_profile_if_required,
                       :verify_authenticity_token

    def index
      return head :not_found unless SiteSetting.kofi_enabled
      return head :bad_request if params.exclude?(:data)

      begin
        payment = Payment.from_json(params[:data])
      rescue ActiveSupport::JSON.parse_error => e
        Rails.error.report(e, handled: true, source: PLUGIN_NAME)
        Rails.logger.warn(
          "Received invalid Ko-fi webhook request. #{e.message}"
        )
        return head :bad_request
      end

      if payment.verification_token != SiteSetting.kofi_webhook_token
        Rails.logger.warn(
          "Invalid Ko-fi webhook token received in request: #{payment.verification_token}."
        )
        # TODO: report somewhere?
        return head :forbidden
      end

      if payment.test_transaction?
        Rails.logger.info(
          "Received Ko-fi test transaction, message id: #{payment.message_id}."
        )
        # TODO: report somewhere?
        return head :ok
      end

      if Payment.find_by_message_id(payment.message_id)
        Rails.logger.warn(
          "Ko-fi message #{payment.message_id} already processed."
        )
        return head :ok
      end
      if Payment.find_by_kofi_transaction_id(payment.kofi_transaction_id)
        Rails.logger.warn(
          "Ko-fi transaction #{payment.kofi_transaction_id} already processed."
        )
        return head :ok
      end

      payment.save
      # Todo: launch process task

      head :ok
    end
  end
end
