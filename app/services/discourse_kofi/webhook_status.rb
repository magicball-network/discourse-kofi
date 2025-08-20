# frozen_string_literal: true

module DiscourseKofi
  class WebhookStatus
    def self.get
      PluginStore.get(PLUGIN_NAME, :status) || {}
    end

    def self.update(success: nil, error: nil)
      status = self.get
      if success
        status["success"] = { timestamp: DateTime.now.to_s, message: success }
        status["error"] = nil
      end
      status["error"] = {
        timestamp: DateTime.now.to_s,
        message: error
      } if error
      PluginStore.set(PLUGIN_NAME, :status, status)
    end
  end
end
