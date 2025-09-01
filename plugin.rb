# frozen_string_literal: true

# name: discourse-kofi
# about: Connect Ko-fi donations and subscriptions with Discourse.
# meta_topic_id: 365158
# version: 0.1
# authors: elmuerte
# url: https://github.com/magicball-network/discourse-kofi
# required_version: 3.4.0

enabled_site_setting :kofi_enabled

register_svg_icon "eye-slash"
register_svg_icon "kofi"
register_svg_icon "kofi-color"

module ::DiscourseKofi
  PLUGIN_NAME = "discourse-kofi"

  module Jobs
  end
end

require_relative "lib/discourse_kofi/engine"

after_initialize do
  on(:user_anonymized) { |user| DiscourseKofi::Anonymizer.anonymize_user(user) }
end
