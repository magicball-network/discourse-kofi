# frozen_string_literal: true

module ::DiscourseKofi
  class AccountSerializer < ApplicationSerializer
    root "account"

    attributes :id, :email, :always_hide, :created_at

    has_one :user, serializer: BasicUserSerializer, embed: :objects
    has_one :latest_payment, serializer: UserPaymentSerializer, embed: :objects
  end
end
