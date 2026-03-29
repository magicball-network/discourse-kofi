# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 Michiel Hendriks
# frozen_string_literal: true

module ::DiscourseKofi
  class BasicBadgeSerializer < ApplicationSerializer
    attributes :id, :name, :enabled, :icon, :image, :badge_type_name

    def name
      object.display_name
    end

    def image
      object.image_url
    end

    def badge_type_name
      object.badge_type.name.downcase
    end
  end
end
