# frozen_string_literal: true

module ::DiscourseKofi
  class BaseRewardSerializer < ApplicationSerializer
    root "reward"

    attributes :id, :enabled, :subscription

    has_one :group, serializer: BasicGroupSerializer, embed: :objects
  end
end
