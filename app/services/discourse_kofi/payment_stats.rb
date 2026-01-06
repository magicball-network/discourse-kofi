# frozen_string_literal: true

module DiscourseKofi
  class PaymentStats
    def self.calculate_leaderboard
      leaderboard = []
      if SiteSetting.kofi_leaderboard_count < 1 ||
           SiteSetting.kofi_leaderboard_types.empty? ||
           SiteSetting.kofi_leaderboard_days == 0
        PluginStore.set(PLUGIN_NAME, :leaderboard, leaderboard)
        return leaderboard
      end

      if SiteSetting.kofi_leaderboard_days == -1
        timestamp_offset = DateTime.new
      else
        timestamp_offset = DateTime.now - SiteSetting.kofi_leaderboard_days.days
      end

      ActiveRecord::Base
        .lease_connection
        .select_all(
          "
              select min(t.from_name) as from_name, u.id as user_id, sum(t.amount) as total, bool_and(t.is_public) as is_public 
              from (
                select coalesce(text(p.user_id), lower(p.email)) as group_id, p.from_name, p.user_id, p.amount, p.is_public
                from discourse_kofi_payments p
                where p.timestamp > $1
                and p.payment_type = any(string_to_array($2, '|'))
              ) t
              left outer join users u on u.id = t.user_id
              group by t.group_id, u.id
              order by total desc
              limit $3
             ",
          "kofi_leaderboard",
          [
            timestamp_offset,
            SiteSetting.kofi_leaderboard_types,
            SiteSetting.kofi_leaderboard_count
          ]
        )
        .each do |row|
          if !row["is_public"]
            leaderboard << { anonymous: true }
          elsif row["user_id"]
            leaderboard << { user_id: row["user_id"] }
          else
            leaderboard << { name: row["from_name"] }
          end
        end

      PluginStore.set(PLUGIN_NAME, :leaderboard, leaderboard)
      leaderboard
    end

    def self.calculate_goal
      goal = { progress: 0, target: nil }
      if SiteSetting.kofi_goal_amount <= 0 || SiteSetting.kofi_goal_types.empty?
        PluginStore.set(PLUGIN_NAME, :goal, goal)
        return goal
      end

      goal[
        :target
      ] = SiteSetting.kofi_goal_amount if SiteSetting.kofi_goal_show_amount

      timestamp_offset =
        DateTime.now - 1.month if SiteSetting.kofi_goal_period == "monthly"
      timestamp_offset =
        DateTime.now - 1.year if SiteSetting.kofi_goal_period == "yearly"

      total =
        Payment
          .where("timestamp > ?", timestamp_offset)
          .where(payment_type: SiteSetting.kofi_goal_types.split("|"))
          .sum(:amount)

      goal[:progress] = (total / SiteSetting.kofi_goal_amount * 100).floor

      PluginStore.set(PLUGIN_NAME, :goal, goal)
      goal
    end

    def self.calculate_summary
    end
  end
end
