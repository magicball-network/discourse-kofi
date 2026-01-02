# frozen_string_literal: true

module ::DiscourseKofi
  # User's view on payments
  class UserPaymentSerializer < PaymentSerializer
    attributes :is_public,
               :kofi_transaction_id,
               :from_name,
               :email,
               :is_subscription_payment,
               :tier_name,
               :account_id

    def show_details(field, always_public = false)
      true
    end
  end
end
