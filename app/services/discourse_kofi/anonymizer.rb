# frozen_string_literal: true

require "digest"

module DiscourseKofi
  class Anonymizer
    def self.anonymize_user(user)
      Account.where(user: user).each { |account| anonymize_account(account) }
    end

    def self.anonymize_payments(email)
      email = Email.downcase(email)
      account = Account.find_by_email(email)
      if account.present?
        anonymize_account(account)
      else
        create_anonymized_account(email)
      end
    end

    def self.anonymize_account(account)
      return if account.anonymized
      account.transaction do
        account.make_anonymous(create_anonymized_email)
        account.save
        update_payments(account)
      end
    end

    private

    def self.create_anonymized_account(email)
      Account.transaction do
        account = Account.new
        account.email = email
        account.save

        Payment.where(email: email, account: nil).update_all(
          account_id: account.id
        )

        anonymize_account(account)
      end
    end

    PAYMENT_BATCH_THRESHOLD = 10
    def self.update_payments(account)
      if account.payments.count < PAYMENT_BATCH_THRESHOLD
        account.payments.each do |payment|
          payment.make_anonymous(account.email)
          payment.save
        end
      else
        ::Jobs.enqueue(Jobs::AnonymizePayments, account_id: account.id)
      end
    end

    EMAIL_SUFFIX = "@kofi-anon.invalid"
    def self.create_anonymized_email()
      user_part = Digest::SHA1.hexdigest(Time.now.to_f.to_s + Random.rand.to_s)
      "#{user_part}#{EMAIL_SUFFIX}"
    end
  end
end
