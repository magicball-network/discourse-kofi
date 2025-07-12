# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class AnonymizePayments < ::Jobs::Base
    BATCH_SIZE = 50

    sidekiq_options queue: "low"

    def execute(args)
      account = DiscourseKofi::Account.find(args[:account_id])
      anonymize_payments(account) if account.present? && account.anonymized
    end

    private

    def anonymize_payments(account)
      count = 0
      account.transaction do
        payments = account.payments.where(anonymized: false).limit(BATCH_SIZE)
        count = payments.count
        payments.each do |payment|
          payment.make_anonymous(account.email)
          payment.save
        end
      end
      if count >= BATCH_SIZE
        ::Jobs.enqueue(AnonymizePayments, account_id: account.id)
      end
    end
  end
end
