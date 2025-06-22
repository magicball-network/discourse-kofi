# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class RewardSerializer < ApplicationSerializer
    attributes :id,
               :subscription,
               :badge_id,
               :badge_name,
               :group_id,
               :group_name,
               :tier_name,
               :payment_types,
               :amount

    def badge_name
      object.badge.name if object.badge
    end

    def group_name
      object.group.name if object.group
    end
  end
end
