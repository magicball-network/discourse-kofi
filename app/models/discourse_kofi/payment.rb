# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class Payment < ActiveRecord::Base
    # Field which are accepted in a JSON payload
    JSON_WHITELIST = %w[
      verification_token
      message_id
      timestamp
      type
      is_public
      from_name
      message
      amount
      url
      email
      currency
      is_subscription_payment
      is_first_subscription_payment
      kofi_transaction_id
      tier_name
    ]
    # Ko-fi uses this transaction ID for test message
    TEST_TRANSACTION_ID = "00000000-1111-2222-3333-444444444444"

    self.table_name = "discourse_kofi_payments"
    self.inheritance_column = nil

    enum :payment_type,
         { donation: 1, subscription: 2, commission: 3, shop_order: 4 },
         prefix: :type

    belongs_to :user, optional: true
    belongs_to :account, class_name: "DiscourseKofi::Account", optional: true

    # Verification token is only used when a message is received, not persisted
    attr_accessor :verification_token

    before_save :update_payment_type, :update_user

    def self.from_json(json)
      hash = ActiveSupport::JSON.decode(json)
      payment = Payment.new
      hash.each do |key, value|
        next if JSON_WHITELIST.exclude?(key)
        payment.send("#{key}=", value)
      end
      payment
    end

    def is_test_transaction
      TEST_TRANSACTION_ID == kofi_transaction_id
    end

    def type=(value)
      super
      self.update_payment_type
    end

    def update_payment_type
      self.payment_type =
        (
          case self.type
          when "Donation"
            :donation
          when "Subscription"
            :subscription
          when "Commission"
            :commission
          when "Shop Order"
            :shop_order
          else
            nil
          end
        )
    end

    def account=(value)
      super
      self.update_user
    end

    def update_user
      if self.account.nil?
        self.user = nil
      else
        self.user = self.account.user
      end
    end
  end
end
