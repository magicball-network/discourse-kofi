# frozen_string_literal: true

module ::DiscourseKofi
  class AccountSerializer < ApplicationSerializer
    attributes :id, :email, :always_hide

    has_one :user, serializer: BasicUserSerializer, embed: :objects
  end
end
