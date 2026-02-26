# frozen_string_literal: true

module ::DiscourseKofi
  class DashboardController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      dashboard = { leaderboard: [], goal: { progress: 0, target: nil } }

      if SiteSetting.kofi_dashboard_enabled == "disabled" ||
           (
             SiteSetting.kofi_dashboard_enabled == "authenticated_only" &&
               current_user.blank?
           )
        render json: dashboard
        return
      end

      dashboard[:leaderboard] = PluginStore.get(PLUGIN_NAME, :leaderboard) ||
        dashboard[:leaderboard]
      dashboard[:goal] = PluginStore.get(PLUGIN_NAME, :goal) || dashboard[:goal]

      render json: dashboard
    end
  end
end
