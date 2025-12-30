# frozen_string_literal: true
#
module ::DiscourseKofi
  class KofiWebhookProblemCheck < ::ProblemCheck
    self.priority = "low"

    def call
      return no_problem unless SiteSetting.kofi_enabled
      status = WebhookStatus.get
      return no_problem if status["error"].nil?

      problem
    end

    def translation_data
      WebhookStatus.get
    end
  end
end
