# frozen_string_literal: true

module DiscourseKofi
  module Users
    class AccountsController < ::ApplicationController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      requires_login

      def index
        accounts =
          AccountQueryBuilder.new(
            params,
            { user: current_user }
          ).find_accounts()
        render_json_dump(accounts: serialize_data(accounts, AccountSerializer))
      end

      def show
        params.require(:id)
        account = Account.find_by(id: params[:id], user: current_user)
        raise Discourse::NotFound unless account

        render_serialized(account, AccountSerializer)
      end

      def update
        params.require(:id)
        account = Account.find_by(id: params[:id], user: current_user)
        raise Discourse::NotFound unless account

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
      end

      def privatize_payments
        params.require(:id)
        account = Account.find_by(id: params[:id], user: current_user)
        raise Discourse::NotFound unless account

        account.transaction do
          Payment.where(account: account).update_all(is_public: false)
        end

        render json: success_json
      end
    end
  end
end
