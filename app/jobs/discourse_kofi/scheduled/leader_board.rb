# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class LeaderBoard < ::Jobs::Scheduled
    every 1.hour

    def execute(args)
      ::DiscourseKofi::PaymentStats.calculate_leaderboard
      ::DiscourseKofi::PaymentStats.calculate_goal
    end
  end
end
