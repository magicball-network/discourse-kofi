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

      payment.transaction do
        payment.account = account
        reward_user(payment)
        payment.save
      end
    end

    def claim_payment(user, reference)
      txid = extract_txid(reference)
      raise PaymentClaimError.new(:invalid_reference) if txid.nil?
      payment = Payment.find_by_kofi_transaction_id(txid)
      raise PaymentClaimError.new(:unknown_reference) if payment.nil?
      raise PaymentClaimError.new(:already_claimed) unless payment.account.nil?

      payment.transaction do
        begin
          account = @accounts.get_user_account(user, payment.email)
        rescue StandardError
          raise PaymentClaimError.new(:account_failure)
        end

        payment.account = account
        payment.is_public = false if account.always_hide
        reward_user(payment)
        payment.save
      end
      payment
    end

    def extract_txid(reference)
      begin
        params = URI.decode_www_form(URI.parse(reference).query || "").to_h
        reference = params["txid"] if params.include?("txid")
      rescue StandardError
        # ignore
      end
      if /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.match?(
           reference
         )
        reference.downcase
      end
    end

    def reward_user(payment, only_reward = nil)
      return if payment.user.nil? || payment.anonymized
      return if only_reward && !only_reward.enabled
      payment.transaction do
        process_rewards(payment, only_reward)
        process_subscription(payment, only_reward) if payment.type_subscription?
      end
    end

    private

    def process_rewards(payment, only_reward = nil)
      if only_reward.present?
        return if only_reward.subscription
        rewards = [only_reward]
      else
        rewards =
          Reward.where(enabled: true, subscription: false).where(
            ":payment_type = ANY(payment_types)",
            payment_type: payment.payment_type
          )
      end
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

    def process_subscription(payment, only_reward = nil)
      return if Subscription.calculate_expiration(payment.timestamp).past?

      if only_reward.present?
        if !only_reward.subscription ||
             !payment.tier_name.casecmp(only_reward.tier_name).zero?
          return
        end
        rewards = [only_reward]
      else
        rewards =
          Reward.where(enabled: true, subscription: true).where(
            "lower(tier_name) = ?",
            payment.tier_name.downcase
          )
      end
      return if rewards.empty?

      subscriptions =
        Subscription
          .where(user: payment.user, reward_id: rewards.map { |r| r.id })
          .map { |s| [s.reward, s] }
          .to_h

      groups_add = []
      groups_remove = []

      rewards.each do |reward|
        sub = subscriptions[reward]
        if sub
          groups_remove << sub.group if sub.group != reward.group
        else
          sub = Subscription.new
          sub.user = payment.user
          sub.reward = reward
        end
        sub.last_payment = payment
        sub.update_rewarded_fields
        sub.save
        groups_add << sub.group

        if sub.activated?
          Notification.create!(
            notification_type: Notification.types[:kofi_subscription_activated],
            user_id: sub.user.id,
            data: { tier_name: sub.tier_name }.to_json
          )
        end
      end

      groups_add
        .uniq()
        .each { |group| group.add(payment.user, notify: true, automatic: true) }

      return if groups_remove.empty?

      existing_groups =
        Subscription
          .where(user: payment.user)
          .where("expires_at > ?", DateTime.now())
          .pluck(:group_id)
      groups_remove.delete_if do |g|
        groups_add.include?(g) || existing_groups.include?(g.id())
      end

      groups_remove.uniq().each { |group| group.remove(payment.user) }
    end
  end
end
