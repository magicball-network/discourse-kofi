# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class AccountsController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        accounts = AccountQueryBuilder.new(params).find_accounts(25)
        render_json_dump(
          accounts: serialize_data(accounts, AdminAccountSerializer)
        )
      end

      def show
        params.require(:id)
        account = Account.find(params[:id])

        render_serialized(account, AdminAccountSerializer)
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def update
        params.require(:id)
        account = Account.find(params[:id])

        # Only allow updating the default visibility
        account.always_hide = params[:always_hide] if params[
          :always_hide
        ].present?
        account.save
        if account.valid?
          StaffActionLogger.new(current_user).log_custom(
            "kofi_account_change",
            log_details(account, true)
          )
          render json: success_json
        else
          render_json_error account.errors
        end
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def privatize_payments
        params.require(:id)
        account = Account.find(params[:id])
        account.transaction do
          Payment.where(account: account).update_all(is_public: false)
        end
        StaffActionLogger.new(current_user).log_custom(
          "kofi_payment_privatized",
          { account_id: account.id }
        )
        render json: success_json
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def anonymize
        params.require(:id)
        account = Account.find(params[:id])
        Anonymizer.anonymize_account(account)
        StaffActionLogger.new(current_user).log_custom(
          "kofi_account_anonymized",
          { account_id: account.id }
        )
        render json: success_json
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def destroy
        params.require(:id)
        account = Account.find(params[:id])
        account.transaction do
          Payment.where(account: account).update_all(
            account_id: nil,
            user_id: nil
          )
          account.destroy
        end
        StaffActionLogger.new(current_user).log_custom(
          "kofi_account_deletion",
          log_details(account)
        )
        render json: success_json
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      ACCOUNT_FIELDS =
        Account.attribute_names.excluding("id", "created_at", "updated_at")

      def log_details(account, update = false)
        details = {}
        if update
          account.previous_changes.each do |f, values|
            details[f.to_sym] = values[1] if ACCOUNT_FIELDS.include?(f)
          end
        else
          details =
            ACCOUNT_FIELDS
              .map { |f| [f, account.public_send(f)] }
              .select { |f, v| v.present? }
              .to_h
        end
        details[:account_id] = account.id
        details
      end
    end
  end
end
