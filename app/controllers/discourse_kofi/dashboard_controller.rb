# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi
  class DashboardController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def index
      return head :not_found unless SiteSetting.kofi_dashboard_enabled

      dashboard = { leaderboard: [], goal: { progress: nil, target: nil } }

      leaderboard = PluginStore.get(PLUGIN_NAME, :leaderboard) || []
      user_ids = leaderboard.map { |e| e[:user_id] }.compact
      users = User.where(id: user_ids).index_by { |e| e.id }

      leaderboard.each do |entry|
        if entry[:user_id]
          user = BasicUserSerializer.new(users[entry[:user_id]], root: "user")
          dashboard[:leaderboard] << user
        else
          dashboard[:leaderboard] << entry
        end
      end

      dashboard[:goal] = PluginStore.get(PLUGIN_NAME, :goal) || dashboard[:goal]

      render json: dashboard
    end
  end
end
