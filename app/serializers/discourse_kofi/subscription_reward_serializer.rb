# frozen_string_literal: true

module ::DiscourseKofi
  class SubscriptionRewardSerializer < BaseRewardSerializer
    attributes :tier_name

    def initialize(object, options = {})
      unless object.subscription
        raise ArgumentError.new("Can only serialize subscription rewards")
      end
      super
    end
  end
end
