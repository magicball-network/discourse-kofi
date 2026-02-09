# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class PaymentsController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        payments = PaymentQueryBuilder.new(params).find_payments()
        render_json_dump(
          payments: serialize_data(payments, AdminPaymentSerializer)
        )
      end

      def show
        params.require(:id)
        payment = Payment.find(params[:id])

        render_serialized(payment, AdminPaymentSerializer)
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def update
        params.require(:id)
        payment = Payment.find(params[:id])

        # Only allow updating the visibility
        payment.is_public = params[:is_public] if params[:is_public].present?
        payment.save
        if payment.valid?
          StaffActionLogger.new(current_user).log_custom(
            "kofi_payment_change",
            {
              kofi_transaction_id: payment.kofi_transaction_id,
              is_public: payment.is_public
            }
          )
          render json: success_json
        else
          render_json_error payment.errors
        end
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def import
        csv_file = params.permit(:file).fetch(:file, nil)
        raise Discourse::InvalidParameters if csv_file.try(:tempfile).nil?
        make_private =
          params[:make_private] == "true" || params[:make_private].nil?
        result =
          PaymentImporter.import_csv(csv_file, make_private: make_private)
        StaffActionLogger.new(current_user).log_custom(
          "kofi_payment_import_csv",
          { count: result[:payments].length }
        )
        render json: result
      rescue CSV::MalformedCSVError => er
        render_json_error I18n.t(
                            "kofi.payments.import.invalid_csv",
                            error: er.message
                          ),
                          status: :bad_request
      end

      def anonymize
        params.require(:email)
        account = Anonymizer.anonymize_payments(params[:email])
        if account
          render_serialized(account, AdminAccountSerializer)
        else
          render json: failed_json, status: :bad_request
        end
      end
    end
  end
end
