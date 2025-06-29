# frozen_string_literal: true

module DiscourseKofi
  module Users
    class PaymentsController < ::ApplicationController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      requires_login

      def index
        # TODO filtering
        payments =
          Payment
            .where(user: current_user)
            .order(timestamp: :desc)
            .offset(params[:offset] || 0)
            .limit(50)

        render_json_dump(
          payments: serialize_data(payments, UserPaymentSerializer)
        )
      end

      def show
        params.require(:id)
        payment = Payment.find_by(id: params[:id], user: current_user)
        raise Discourse::NotFound unless payment

        render_serialized(payment, UserPaymentSerializer)
      end

      def update
        params.require(:id)
        payment = Payment.find_by(id: params[:id], user: current_user)
        raise Discourse::NotFound unless payment

        # Only allow updating the visibility
        payment.is_public = params[:is_public] if params[:is_public].present?
        payment.save
        if payment.valid?
          render json: success_json
        else
          render_json_error payment.errors
        end
      end

      def claim
        # TODO
      end
    end
  end
end
