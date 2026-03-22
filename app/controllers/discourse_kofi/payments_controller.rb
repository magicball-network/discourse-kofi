# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi
  class PaymentsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      return head :not_found unless SiteSetting.kofi_dashboard_enabled

      if current_user.present?
        visible_details =
          SiteSetting.kofi_dashboard_authenticated_view.split("|")
      else
        visible_details = SiteSetting.kofi_dashboard_anonymous_view.split("|")
      end

      if visible_details.empty?
        render json: []
        return
      end

      query =
        Payment.where(
          "payment_type IN (:payment_types)",
          payment_types: SiteSetting.kofi_dashboard_types.split("|")
        ).where(
          # Only include first subscription payment; only that one has a message
          "is_subscription_payment = false or is_first_subscription_payment = true"
        )

      if visible_details.exclude?("include_unknown_users")
        query = query.where("user_id is not null")
      end

      payments =
        query.order(timestamp: :desc).limit(SiteSetting.kofi_dashboard_count)

      render_json_dump(
        payments:
          serialize_data(
            payments,
            PaymentSerializer,
            visible_details: visible_details
          )
      )
    end
  end
end
