# frozen_string_literal: true

module ::DiscourseKofi
  class Subscription < ActiveRecord::Base
    self.table_name = "discourse_kofi_subscriptions"

    belongs_to :user
    belongs_to :reward
    belongs_to :group
    belongs_to :last_payment, class_name: "DiscourseKofi::Payment"

    validates :user, :reward, :last_payment, :group, :tier_name, presence: true

    before_save :update_expires

    def self.calculate_expiration(timestamp)
      # Add 1 day slack
      timestamp + 1.month + 1.day
    end

    def expired?
      self.expires_at.nil? || self.expires_at.past?
    end

    def activated?
      @activated == true
    end

    def update_rewarded_fields
      self.group = self.reward.group
      self.tier_name = self.reward.tier_name
    end

    private

    def update_expires
      was_expired = self.expired?
      self.expires_at =
        Subscription.calculate_expiration(self.last_payment.timestamp)
      @activated = was_expired && !self.expired?
    end
  end
end

# == Schema Information
#
# Table name: discourse_kofi_subscriptions
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  reward_id       :bigint           not null
#  last_payment_id :bigint           not null
#  tier_name       :string           not null
#  group_id        :bigint           not null
#  expires_at      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_discourse_kofi_subscriptions_on_group_id               (group_id)
#  index_discourse_kofi_subscriptions_on_last_payment_id        (last_payment_id)
#  index_discourse_kofi_subscriptions_on_reward_id              (reward_id)
#  index_discourse_kofi_subscriptions_on_user_id                (user_id)
#  index_discourse_kofi_subscriptions_on_user_id_and_reward_id  (user_id,reward_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (last_payment_id => discourse_kofi_payments.id)
#  fk_rails_...  (reward_id => discourse_kofi_rewards.id)
#  fk_rails_...  (user_id => users.id)
#
