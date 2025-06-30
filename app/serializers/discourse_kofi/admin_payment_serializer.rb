# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class AdminPaymentSerializer < UserPaymentSerializer
    attributes :is_first_subscription_payment, :message_id, :url, :anonymized
  end
end
