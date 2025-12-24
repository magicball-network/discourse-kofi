# frozen_string_literal: true

# name: discourse-kofi
# about: Connect Ko-fi donations and subscriptions with Discourse.
# meta_topic_id:
# version: 0.1
# authors: elmuerte
# url: https://github.com/magicball-network/discourse-kofi
# required_version: 3.5.0

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
require_relative "lib/discourse_kofi/reports"

after_initialize do
  require_relative "app/jobs/discourse_kofi/scheduled/subscription_expiration"

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

  register_stat("kofi_payment_totals", expose_via_api: true) do
    DiscourseKofi::Statistics.payment_totals
  end

  add_report("kofi_payments") do |report|
    DiscourseKofi::Reports.payments(report)
  end
  add_report("kofi_payment_amount") do |report|
    DiscourseKofi::Reports.payment_amount(report)
  end
end
