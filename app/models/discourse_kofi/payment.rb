# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class Payment < ActiveRecord::Base
    PAYMENT_TYPES = {
      donation: "donation",
      subscription: "subscription",
      commission: "commission",
      shop_order: "shop_order"
    }.freeze

    # Fields which are accepted in a JSON payload
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
    ].freeze

    # Ko-fi uses this transaction ID for test message
    TEST_TRANSACTION_ID = "00000000-1111-2222-3333-444444444444"

    self.table_name = "discourse_kofi_payments"
    self.inheritance_column = nil

    enum :payment_type, PAYMENT_TYPES, prefix: :type

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

    def self.user_total(user)
      Payment
        .where(user: user)
        .group(:payment_type)
        .pluck(:payment_type, "sum(amount)")
        .to_h
    end

    def test_transaction?
      TEST_TRANSACTION_ID == kofi_transaction_id
    end

    def type=(value)
      super
      update_payment_type
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
      update_user
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

# == Schema Information
#
# Table name: discourse_kofi_payments
#
#  id                            :bigint           not null, primary key
#  message_id                    :string           not null
#  timestamp                     :datetime         not null
#  type                          :string           not null
#  is_public                     :boolean          not null
#  from_name                     :string
#  message                       :string
#  amount                        :decimal(15, 2)   not null
#  url                           :string
#  email                         :string
#  currency                      :string           not null
#  is_subscription_payment       :boolean          not null
#  is_first_subscription_payment :boolean          not null
#  kofi_transaction_id           :string           not null
#  tier_name                     :string
#  payment_type                  :string           not null
#  account_id                    :bigint
#  user_id                       :bigint
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_discourse_kofi_payments_on_account_id           (account_id)
#  index_discourse_kofi_payments_on_kofi_transaction_id  (kofi_transaction_id) UNIQUE
#  index_discourse_kofi_payments_on_message_id           (message_id) UNIQUE
#  index_discourse_kofi_payments_on_payment_type         (payment_type)
#  index_discourse_kofi_payments_on_tier_name            (tier_name) WHERE (tier_name IS NOT NULL)
#  index_discourse_kofi_payments_on_timestamp            (timestamp)
#  index_discourse_kofi_payments_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => discourse_kofi_accounts.id)
#  fk_rails_...  (user_id => users.id)
#
