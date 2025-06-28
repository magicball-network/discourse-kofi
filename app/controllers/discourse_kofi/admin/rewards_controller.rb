# frozen_string_literal: true

module DiscourseKofi
  module Admin
    class RewardsController < ::Admin::AdminController
      requires_plugin DiscourseKofi::PLUGIN_NAME

      def index
        rewards =
          DiscourseKofi::Reward.where(subscription: false).order(:amount)
        subscriptions =
          DiscourseKofi::Reward.where(subscription: true).order(
            "lower(tier_name)"
          )
        render_json_dump(
          rewards: serialize_data(rewards, RewardSerializer),
          subscriptions:
            serialize_data(subscriptions, SubscriptionRewardSerializer)
        )
      end

      def show
        render_reward(find_reward)
      end

      def create
        reward = Reward.new
        errors = update_reward_from_params(reward, new: true)
        if errors.present?
          render_json_error errors
        else
          StaffActionLogger.new(current_user).log_custom(
            "kofi_reward_creation",
            log_details(reward)
          )
          render_reward(reward)
        end
      end

      def update
        reward = find_reward
        errors = update_reward_from_params(reward)
        if errors.present?
          render_json_error errors
        else
          StaffActionLogger.new(current_user).log_custom(
            "kofi_reward_change",
            log_details(reward, update: true)
          )
          render_reward(reward)
        end
      end

      def destroy
        Reward.transaction do
          reward = find_reward
          StaffActionLogger.new(current_user).log_custom(
            "kofi_reward_deletion",
            log_details(reward)
          )
          reward.destroy!
        end
        render json: success_json
      end

      private

      def render_reward(reward)
        if reward.subscription
          render_serialized(reward, SubscriptionRewardSerializer)
        else
          render_serialized(reward, RewardSerializer)
        end
      end

      def find_reward
        params.require(:id)
        reward = Reward.find(params[:id])
        raise Discourse::NotFound unless reward
        reward
      end

      def update_reward_from_params(reward, opts = {})
        errors = []
        Reward.transaction do
          allowed = Reward.column_names.map(&:to_sym)
          allowed -= %i[id created_at updated_at]
          allowed -= %i[subscription] unless opts[:new]
          params.permit(*allowed)

          allowed.each do |key|
            reward.public_send("#{key}=", params[key]) if params[key]
          end

          reward.id = nil if opts[:new]
          reward.save!
        end

        if opts[:new].blank?
          #TODO schedule mass reward
        end

        errors
      rescue ActiveRecord::RecordInvalid
        errors.push(*reward.errors.full_messages)
        errors
      end

      REWARD_FIELDS =
        Reward.attribute_names.excluding("id", "created_at", "updated_at")

      def log_details(reward, update = false)
        details = {}
        if update
          details[:subscription] = reward.subscription
          reward.previous_changes.each do |f, values|
            details[f.to_sym] = values[1] if REWARD_FIELDS.include?(f)
          end
        else
          details =
            REWARD_FIELDS
              .map { |f| [f, reward.public_send(f)] }
              .select { |f, v| v.present? }
              .to_h
        end
        details[:reward_id] = reward.id
        details
      end
    end
  end
end
