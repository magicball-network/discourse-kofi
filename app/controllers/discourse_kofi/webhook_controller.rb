# frozen_string_literal: true

module ::DiscourseKofi
  class WebhookController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    layout false

    skip_before_action :check_xhr,
                       :redirect_to_login_if_required,
                       :redirect_to_profile_if_required,
                       :verify_authenticity_token

    def index
      Rails.logger.info("Ko-fi webhook: #{params[:data]}")
      render plain: nil, status: :ok
    end
  end
end
