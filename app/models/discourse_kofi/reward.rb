# frozen_string_literal: true

module ::DiscourseKofi
  class Reward < ActiveRecord::Base
    self.table_name = "discourse_kofi_rewards"

    attribute :subscription, :boolean, default: false
    attribute :payment_types, :string, array: true

    belongs_to :badge
    belongs_to :group

    with_options if: :subscription? do |reward|
      reward.validates :tier_name, :group, presence: true

      reward.validates :badge, :payment_types, :amount, absence: true
    end

    with_options unless: :subscription? do |reward|
      reward.validates :tier_name, absence: true

      reward.validates :payment_types, presence: true

      reward.validates :amount, numericality: { greater_than_or_equal_to: 0 }

      reward.validates :badge,
                       presence: true,
                       unless: Proc.new { |r| r.group.present? }
      reward.validates :group,
                       presence: true,
                       unless: Proc.new { |r| r.badge.present? }
    end

    validate :valid_payment_types, unless: :subscription?

    def valid_payment_types
      if !payment_types.kind_of?(Array)
        errors.add(:payment_types, "must be an array")
      elsif payment_types.empty?
        errors.add(:payment_types, "must contain at least one value")
      else
        payment_types.each do |payment_type|
          if !Payment::PAYMENT_TYPES.keys.include?(payment_type.to_sym)
            errors.add(
              :payment_types,
              "'#{payment_type}' is not a valid payment type"
            )
          end
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: discourse_kofi_rewards
#
#  id            :bigint           not null, primary key
#  badge_id      :bigint
#  group_id      :bigint
#  subscription  :boolean          not null
#  tier_name     :string
#  payment_types :string           is an Array
#  amount        :decimal(15, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_discourse_kofi_rewards_on_badge_id  (badge_id)
#  index_discourse_kofi_rewards_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (badge_id => badges.id)
#  fk_rails_...  (group_id => groups.id)
#
