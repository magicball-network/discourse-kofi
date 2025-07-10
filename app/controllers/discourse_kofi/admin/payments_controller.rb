# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class PaymentsController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        # TODO filtering
        payments =
          Payment.order(timestamp: :desc).offset(params[:offset] || 0).limit(50)
        render_json_dump(
          payments: serialize_data(payments, UserPaymentSerializer)
        )
      end

      def show
        params.require(:id)
        payment = Payment.find(params[:id])
        raise Discourse::NotFound unless payment

        render_serialized(payment, AdminPaymentSerializer)
      end

      def update
        params.require(:id)
        payment = Payment.find(params[:id])
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

      def import
        csv_file = params.permit(:file).fetch(:file, nil)
        raise Discourse::InvalidParameters if csv_file.try(:tempfile).nil?
        make_private =
          params[:make_private] == "true" || params[:make_private].nil?
        result =
          PaymentImporter.import_csv(csv_file, make_private: make_private)
        render json: result
      rescue CSV::MalformedCSVError => er
        render_json_error I18n.t(
                            "kofi.payments.import.invalid_csv",
                            error: er.message
                          ),
                          status: 400
      end

      def anonymize
        params.require(:email)
        Anonymizer.anonymize_payments(params[:email])
        render json: success_json
      end
    end
  end
end
