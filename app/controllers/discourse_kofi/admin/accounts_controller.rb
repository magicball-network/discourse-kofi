# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class AccountsController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        accounts =
          Account
            .order(created_at: :desc)
            .offset(params[:offset] || 0)
            .limit(50)

        if params[:filter].present?
          accounts =
            accounts.joins(:user).where(
              "email ILIKE :filter or users.username_lower ILIKE :filter",
              filter: "%#{params[:filter].downcase}%"
            )
        end

        render_json_dump(
          accounts: serialize_data(accounts, AdminAccountSerializer)
        )
      end

      def show
        params.require(:id)
        account = Account.find(params[:id])
        raise Discourse::NotFound unless account

        render_serialized(account, AdminAccountSerializer)
      end

      def destroy
        # TODO
      end

      def anonymize
        # TODO create an anonymized account
      end
    end
  end
end
