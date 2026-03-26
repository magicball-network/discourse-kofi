# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

# name: discourse-kofi
# about: Connect Ko-fi donations and subscriptions with Discourse.
# meta_topic_id:
# version: 0.1
# authors: elmuerte
# url: https://github.com/magicball-network/discourse-kofi
# required_version: 2026.1

enabled_site_setting :kofi_enabled

register_svg_icon "kofi"
register_svg_icon "kofi-color"
register_svg_icon "eye-slash"
register_svg_icon "file-import"
register_svg_icon "eraser"

register_asset "stylesheets/common/admin.scss"
register_asset "stylesheets/common/main.scss"

module ::DiscourseKofi
  PLUGIN_NAME = "discourse-kofi"

  module Jobs
  end
end

require_relative "lib/discourse_kofi/engine"

after_initialize do
  require_relative "lib/discourse_kofi/seed"
  add_topic_static_page(
    "kofi-dashboard",
    { topic_id: "kofi_dashboard_topic_id" }
  )

  on_enabled_change do |old_value, new_value|
    DiscourseKofi::Seed.seed_me_seymour if new_value
  end

  on(:site_setting_changed) do |name, old_value, new_value|
    DiscourseKofi::Seed.seed_or_feed if %i[kofi_account title].include?(name)

    if name.to_s.starts_with?("kofi_goal_")
      ::Jobs.enqueue_in(
        1.minute,
        DiscourseKofi::Jobs::LeaderBoard,
        calculate: ["goal"]
      )
    end

    if name.to_s.starts_with?("kofi_leaderboard_")
      ::Jobs.enqueue_in(
        1.minute,
        DiscourseKofi::Jobs::LeaderBoard,
        calculate: ["leaderboard"]
      )
    end
  end

  require_relative "app/jobs/discourse_kofi/scheduled/subscription_expiration"
  require_relative "app/jobs/discourse_kofi/scheduled/leader_board"

  extend_list_method(
    UserHistory,
    :staff_actions,
    %i[
      kofi_reward_creation
      kofi_reward_change
      kofi_reward_deletion
      kofi_account_change
      kofi_payment_privatized
      kofi_account_anonymized
      kofi_account_deletion
      kofi_payment_privatized
      kofi_payment_change
    ]
  )

  Notification.types[:kofi_account_link] = 53_900
  Notification.types[:kofi_subscription_activated] = 53_910
  Notification.types[:kofi_subscription_expired] = 53_911
  Notification.types[:kofi_subscription_joined_group] = 53_912
  Notification.types[:kofi_subscription_left_group] = 53_913

  on(:user_anonymized) { |user| DiscourseKofi::Anonymizer.anonymize_user(user) }

  add_to_serializer(
    :group_show,
    :kofi_rewards,
    include_condition: -> { scope.is_admin? }
  ) { DiscourseKofi::Reward.where(group: object).pluck(:id) }

  add_to_serializer(
    :badge,
    :kofi_rewards,
    include_condition: -> { scope.is_admin? }
  ) { DiscourseKofi::Reward.where(badge: object).pluck(:id) }

  require_relative "lib/discourse_kofi/reports"
  add_report("kofi_payments") do |report|
    DiscourseKofi::Reports.payments(report)
  end
  add_report("kofi_payment_amount") do |report|
    DiscourseKofi::Reports.payment_amount(report)
  end

  require_relative "lib/discourse_kofi/problem_check/config"
  register_problem_check(DiscourseKofi::KofiConfigProblemCheck)
  require_relative "lib/discourse_kofi/problem_check/webhook"
  register_problem_check(DiscourseKofi::KofiWebhookProblemCheck)
end
