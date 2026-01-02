# frozen_string_literal: true

module ::DiscourseKofi
  class RewardSerializer < BaseRewardSerializer
    attributes :payment_types, :amount

    has_one :badge, serializer: BasicBadgeSerializer, embed: :objects

    def initialize(object, options = {})
      if object.subscription
        raise ArgumentError.new("Cannot serialize subscription rewards")
      end
      super
    end
  end
end
