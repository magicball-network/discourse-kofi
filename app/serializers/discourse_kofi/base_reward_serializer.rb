# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class BaseRewardSerializer < ApplicationSerializer
    root "reward"

    attributes :id, :enabled, :subscription

    has_one :group, serializer: IdNameSerializer, embed: :objects
  end
end
