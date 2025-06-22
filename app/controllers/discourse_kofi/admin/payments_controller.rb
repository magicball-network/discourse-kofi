# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class PaymentsController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        # TODO filtering
        payments =
          Payment.order(timestamp: :desc).offset(params[:offset] || 0).limit(50)
        render_serialized(payments, AdminPaymentSerializer)
      end

      def show
        params.require(:id)
        payment = Payment.find(params[:id])
        render_serialized(payment, AdminPaymentSerializer)
      end

      def update
        params.require(:id)
        payment = Payment.find(params[:id])
        # Only allow updating the visibility
        payment.is_public = params[:is_public]
        payment.save
        if payment.valid?
          render_serialized(payment, AdminPaymentSerializer)
        else
          render_json_error payment.errors
        end
      end
    end
  end
end
