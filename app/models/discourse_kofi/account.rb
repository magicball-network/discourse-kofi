# frozen_string_literal: true

require "digest"

module ::DiscourseKofi
  class Account < ActiveRecord::Base
    self.table_name = "discourse_kofi_accounts"

    attr_readonly :email_hash

    belongs_to :user
    has_many :payments, class_name: "DiscourseKofi::Payment"
    has_one :latest_payment,
            -> { Payment.order(timestamp: "desc").limit(1) },
            class_name: "DiscourseKofi::Payment"

    before_create do
      self.email_hash = Account.hash_email(self.email) if self.email_hash.nil?
    end

    def self.hash_email(email)
      Digest::SHA2.hexdigest(Email.downcase(email))
    end

    def email=(value)
      super(Email.downcase(value))
    end

    def make_anonymous(email)
      # assumes the email is an anonymized one
      self.email = email
      self.anonymized = true
      self.always_hide = true
    end
  end
end

# == Schema Information
#
# Table name: discourse_kofi_accounts
#
#  id          :bigint           not null, primary key
#  email       :string           not null
#  user_id     :bigint
#  always_hide :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  email_hash  :string           not null
#  anonymized  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_discourse_kofi_accounts_on_email       (email) UNIQUE
#  index_discourse_kofi_accounts_on_email_hash  (email_hash) UNIQUE
#  index_discourse_kofi_accounts_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
