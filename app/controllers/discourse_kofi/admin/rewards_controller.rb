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
        render json: { rewards: rewards, subscriptions: subscriptions }
      end

      def show
        #TODO
      end

      def create
        #TODO
      end

      def update
        #TODO
      end

      def destroy
        #TODO
      end
    end
  end
end
