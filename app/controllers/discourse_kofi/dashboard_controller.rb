# frozen_string_literal: true

module ::DiscourseKofi
  class DashboardController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      dashboard = { leaderboard: [], goal: { progress: 0, target: 0 } }

      unless SiteSetting.kofi_dashboard_enabled
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
