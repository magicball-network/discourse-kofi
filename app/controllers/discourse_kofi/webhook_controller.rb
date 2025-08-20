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
        WebhookStatus.update(
          error:
            I18n.t(
              "kofi.webhook.status.invalid_token",
              msg_id: payment.message_id,
              tx_id: payment.kofi_transaction_id,
              verification_token: payment.verification_token
            )
        )
        return head :forbidden
      end

      if payment.test_transaction?
        Rails.logger.info(
          "Received Ko-fi test transaction, message id: #{payment.message_id}."
        )
        WebhookStatus.update(
          success:
            I18n.t(
              "kofi.webhook.status.test_transaction",
              msg_id: payment.message_id,
              tx_id: payment.kofi_transaction_id
            )
        )
        return head :ok
      end

      if Payment.find_by_message_id(payment.message_id)
        Rails.logger.warn(
          "Ko-fi message #{payment.message_id} already processed."
        )
        WebhookStatus.update(
          success:
            I18n.t(
              "kofi.webhook.status.duplicate_message",
              msg_id: payment.message_id,
              tx_id: payment.kofi_transaction_id
            )
        )
        return head :ok
      end
      if Payment.find_by_kofi_transaction_id(payment.kofi_transaction_id)
        Rails.logger.warn(
          "Ko-fi transaction #{payment.kofi_transaction_id} already processed."
        )
        WebhookStatus.update(
          success:
            I18n.t(
              "kofi.webhook.status.known_transaction",
              msg_id: payment.message_id,
              tx_id: payment.kofi_transaction_id
            )
        )
        return head :ok
      end

      WebhookStatus.update(
        success:
          I18n.t(
            "kofi.webhook.status.message_received",
            msg_id: payment.message_id,
            tx_id: payment.kofi_transaction_id
          )
      )

      payment.save
      ::Jobs.enqueue(Jobs::ResolvePayment, payment_id: payment.id)

      head :ok
    end
  end
end
