# frozen_string_literal: true
#
module ::DiscourseKofi
  class KofiConfigProblemCheck < ::ProblemCheck
    self.priority = "low"

    def call
      return no_problem unless SiteSetting.kofi_enabled
      return no_problem if SiteSetting.kofi_webhook_token.present?

      problem
    end
  end
end
