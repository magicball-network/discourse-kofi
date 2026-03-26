# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class LeaderBoard < ::Jobs::Scheduled
    every 1.hour

    def execute(args)
      return unless SiteSetting.kofi_enabled
      calc = args["calculate"] || []
      if calc.empty? || calc.include?("leaderboard")
        ::DiscourseKofi::PaymentStats.calculate_leaderboard
      end
      if calc.empty? || calc.include?("goal")
        ::DiscourseKofi::PaymentStats.calculate_goal
      end
    end
  end
end
