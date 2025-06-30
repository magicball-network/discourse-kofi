# frozen_string_literal: true

require "uri"

module DiscourseKofi
  class PaymentClaimError < StandardError
    attr_reader :failure
    def initialize(failure)
      @failure = failure
    end
  end

  class PaymentProcessor
    def initialize
      @accounts = AccountManagement.new
    end

    def resolve_payment(id)
      payment = Payment.find(id)
      return if payment.nil? || !payment.user.nil?

      account = @accounts.find_account(payment.email)
      return if account.nil?
      payment.account = account
      # possibly update email if it was matched on email hash
      payment.email = account.email
      payment.is_public = false if account.always_hide
      payment.anonymize if account.anonymized
      reward_user(payment)
      payment.save
    end

    def claim_payment(user, reference)
      txid = extract_txid(reference)
      raise PaymentClaimError.new(:invalid_reference) if txid.nil?
      payment = Payment.find_by_kofi_transaction_id(txid)
      raise PaymentClaimError.new(:unknown_reference) if payment.nil?
      raise PaymentClaimError.new(:already_claimed) unless payment.account.nil?

      begin
        account = @accounts.get_user_account(user, payment.email)
      rescue StandardError
        raise PaymentClaimError.new(:account_failure)
      end

      payment.account = account
      payment.is_public = false if account.always_hide
      reward_user(payment)
      payment.save
      payment
    end

    def extract_txid(reference)
      begin
        params = URI.decode_www_form(URI.parse(reference).query || "").to_h
        reference = params["txid"] if params.include?("txid")
      rescue StandardError
        # ignore
      end
      if /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match?(
           reference
         )
        reference
      end
    end

    def reward_user(payment)
      return if payment.user.nil? || payment.anonymized
      process_rewards(payment)
      process_subscription(payment) if payment.type_subscription?
    end

    private

    def process_rewards(payment)
      rewards =
        Reward.where(enabled: true, subscription: false).where(
          ":payment_type = ANY(payment_types)",
          payment_type: payment.payment_type
        )
      return if rewards.empty?

      user_totals = Payment.user_total(payment.user)
      rewards.each do |reward|
        total = sum_totals(user_totals, reward.payment_types)
        process_reward(payment, reward) if total >= reward.amount
      end
    end

    def sum_totals(user_totals, payment_types)
      total = 0
      payment_types.each do |type|
        total += user_totals[type] unless user_totals[type].nil?
      end
      total
    end

    def process_reward(payment, reward)
      BadgeGranter.grant(reward.badge, payment.user) unless reward.badge.nil?
      unless reward.group.nil?
        reward.group.add(payment.user, notify: true, automatic: true)
      end
    end

    def process_subscription(payment)
      # TODO
      # find associated group if any
    end
  end
end
