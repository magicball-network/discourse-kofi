# frozen_string_literal: true

module ::DiscourseKofi
  class BasicBadgeSerializer < ApplicationSerializer
    attributes :id, :name, :enabled, :icon, :image, :badgeTypeClassName

    def name
      object.display_name
    end

    def image
      object.image_url
    end

    def badgeTypeClassName
      "badge-type-" + object.badge_type.name.downcase
    end
  end
end
