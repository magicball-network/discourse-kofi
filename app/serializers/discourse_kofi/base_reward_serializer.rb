# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class IdNameSerializer < ApplicationSerializer
    attributes :id, :name
  end

  class BaseRewardSerializer < ApplicationSerializer
    attributes :id

    has_one :group, serializer: IdNameSerializer, embed: :objects
  end
end
