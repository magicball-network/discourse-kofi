# frozen_string_literal: true

module ::DiscourseKofi
  class PaymentsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      if SiteSetting.kofi_dashboard_enabled == "disabled"
        render json: [], root: false
        return
      end
      if SiteSetting.kofi_dashboard_enabled == "authenticated_only" &&
           current_user.blank?
        render json: [], root: false
        return
      end

      payments =
        Payment
          .where(
            "payment_type IN (:payment_types)",
            payment_types: SiteSetting.kofi_dashboard_types.split("|")
          )
          .order(timestamp: :desc)
          .limit(SiteSetting.kofi_dashboard_count)

      if current_user.present?
        visible_details =
          SiteSetting.kofi_dashboard_authenticated_view.split("|")
      else
        visible_details = SiteSetting.kofi_dashboard_anonymous_view.split("|")
      end

      render_serialized(
        payments,
        PaymentSerializer,
        visible_details: visible_details
      )
    end
  end
end
