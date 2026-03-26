# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi
  class Seed
    def self.seed_me_seymour
      return unless SiteSetting.kofi_needs_seed
      I18n.with_locale(SiteSetting.default_locale) { self.do_create_topic }
      SiteSetting.kofi_needs_seed = false
    end

    def self.seed_or_feed
      I18n.with_locale(SiteSetting.default_locale) do
        if SiteSetting.kofi_needs_seed
          self.do_create_topic
        else
          self.do_update_topic
        end
      end
    end

    private

    def self.do_create_topic
      topic_id = SiteSetting.kofi_dashboard_topic_id
      return if topic_id > 0 || Topic.find_by(id: topic_id)

      category = Category.find_by(id: SiteSetting.staff_category_id)
      title = I18n.t("kofi.dashboard.topic.title")
      raw = self.get_post_body

      post =
        PostCreator.create!(
          Discourse.system_user,
          title: title,
          raw: raw,
          skip_jobs: true,
          skip_validations: true,
          category: category&.id
        )

      PostCreator.create!(
        Discourse.system_user,
        raw: I18n.t("kofi.dashboard.topic.first_reply"),
        skip_jobs: true,
        skip_validations: true,
        topic_id: post.topic_id
      )

      SiteSetting.kofi_dashboard_topic_id = post.topic_id
    end

    def self.do_update_topic
      topic_id = SiteSetting.kofi_dashboard_topic_id
      return if topic_id <= 0
      posts = Post.where(topic_id: topic_id, post_number: 1)
      posts = posts.with_deleted
      post = posts.first
      return unless post

      return if post.last_editor_id != Discourse::SYSTEM_USER_ID

      if post.trashed?
        PostDestroyer.new(
          Discourse.system_user,
          post,
          context: I18n.t("staff_action_logs.seed_data_topic_updated")
        ).recover
        post.reload
      end

      post.revise(
        Discourse.system_user,
        {
          title: I18n.t("kofi.dashboard.topic.title"),
          raw: self.get_post_body
        },
        skip_validations: true
      )
    end

    def self.get_post_body
      I18n.t(
        "kofi.dashboard.topic.body",
        site_title: SiteSetting.title,
        kofi_account: SiteSetting.kofi_account
      )
    end
  end
end
