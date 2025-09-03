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
        render json: success_json
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end

      def anonymize
        params.require(:id)
        Anonymizer.anonymize_account(Account.find(params[:id]))
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
        render json: success_json
      rescue ActiveRecord::RecordNotFound
        raise Discourse::NotFound
      end
    end
  end
end
