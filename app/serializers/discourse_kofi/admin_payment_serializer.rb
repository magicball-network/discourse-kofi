# frozen_string_literal: true

module ::DiscourseKofi
  class AdminPaymentSerializer < UserPaymentSerializer
    attributes :is_first_subscription_payment, :message_id, :url, :anonymized
  end
end
