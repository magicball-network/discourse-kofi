# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class RewardSerializer < BaseRewardSerializer
    attributes :payment_types, :amount

    has_one :badge, serializer: IdNameSerializer, embed: :objects

    def initialize(object, options = {})
      if object.subscription
        raise ArgumentError.new("Cannot serialize subscription rewards")
      end
      super
    end
  end
end
