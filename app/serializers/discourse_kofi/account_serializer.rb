# frozen_string_literal: true

module ::DiscourseKofi
  class AccountSerializer < ApplicationSerializer
    root "account"

    attributes :id, :email, :always_hide

    has_one :user, serializer: BasicUserSerializer, embed: :objects
  end
end
