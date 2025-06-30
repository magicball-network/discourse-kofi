# frozen_string_literal: true

module ::DiscourseKofi
  class AdminAccountSerializer < AccountSerializer
    attributes :email_hash, :anonymized
  end
end
