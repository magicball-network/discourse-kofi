# frozen_string_literal: true

require "active_support/json"

module ::DiscourseKofi
  class PaymentSerializer < ApplicationSerializer
    attributes :id,
               :timestamp,
               :payment_type,
               :message,
               :amount_currency,
               :username,
               :user_id

    def initialize(object, opts = nil)
      super
      if opts.nil? || opts[:visible_details].nil?
        @visible_details = []
      else
        @visible_details = opts[:visible_details]
      end
    end

    def message
      object.message if show_details(:message)
    end

    def amount_currency
      if show_details(:amount, always_public: true)
        ActiveSupport::NumberHelper.number_to_currency(
          object.amount,
          precision: 2,
          unit: currency_unit
        )
      end
    end

    def currency_unit
      case object.currency
      when "USD"
        "$"
      when "EUR"
        "€"
      when "GBP"
        "£"
      when "AUD"
        "$"
      when "BRL"
        "R$"
      when "CAD"
        "$"
      when "JPY"
        "¥"
      when "SGD"
        "S$"
      when "THB"
        "฿"
      when "NZD"
        "$"
      else
        "#{currency} "
      end
    end

    def username
      return nil unless show_details(:user)
      return object.user.name if object.user
      object.from_name
    end

    def user_id
      return nil unless show_details(:user)
      object.user.id if object.user
    end

    def show_details(field, always_public: false)
      @visible_details.include?(field.to_s) &&
        (object.is_public || always_public)
    end
  end
end
