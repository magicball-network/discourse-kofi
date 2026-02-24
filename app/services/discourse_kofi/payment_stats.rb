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
        # Since for ever, well... Julian day
        timestamp_offset = DateTime.new
      else
        timestamp_offset = DateTime.now - SiteSetting.kofi_leaderboard_days.days
      end

      ActiveRecord::Base
        .lease_connection
        .select_all(
          "
              select 
                case when p.user_id is not null then text(p.user_id) else p.email end as account,
                (select n.from_name from discourse_kofi_payments n where n.id = max(p.id)) as from_name,
                p.user_id as user_id,
                max(p.id) as last_payment_id, 
                sum(p.amount) as total, 
                bool_and(is_public) as is_public
              from discourse_kofi_payments p
              where p.timestamp > $1
              and p.payment_type = any(string_to_array($2, '|'))
              group by account, user_id
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
            leaderboard << { user_id: row["user_id"].to_i }
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
      timestamp_offset =
        DateTime.iso8601(
          SiteSetting.kofi_goal_since
        ) if SiteSetting.kofi_goal_period == "since"

      total =
        Payment
          .where("timestamp > ?", timestamp_offset)
          .where(payment_type: SiteSetting.kofi_goal_types.split("|"))
          .sum(:amount)

      goal[:progress] = (total / SiteSetting.kofi_goal_amount * 100).floor

      PluginStore.set(PLUGIN_NAME, :goal, goal)

      if SiteSetting.kofi_goal_progress_bar_integration
        update_progress_bar(SiteSetting.kofi_goal_amount, total)
      end
      goal
    end

    def self.calculate_summary
      # TODO
    end

    private

    def self.update_progress_bar(target, total)
      theme =
        Theme.joins(:remote_theme).find_by(
          "remote_url = ?",
          "https://github.com/Canapin/Discourse-progress-bar.git"
        )
      return unless theme
      theme.update_setting(:max_value, target.to_i)
      theme.update_setting(:current_value, total.to_i)
      theme.save
    end
  end
end
