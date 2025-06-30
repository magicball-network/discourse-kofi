# frozen_string_literal: true

module DiscourseKofi
  class Anonymizer
    def self.anonymize_user(user)
      #TODO
      # - make all payments private?
      # - remove user name and email from payments?
      # - remove email from accounts?
      # - or just remove accounts?
      # - or hash email and make accounts anonymous?
    end

    def self.anonymize_payment(email)
      #TODO
      # - remove user name and email from payments?
      # - what about accounts?
    end
  end
end
