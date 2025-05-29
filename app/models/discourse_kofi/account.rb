# frozen_string_literal: true

module ::DiscourseKofi
  class Account < ActiveRecord::Base
    self.table_name = "discourse_kofi_accounts"

    belongs_to :user, optional: true
    has_many :payments, class_name: "DiscourseKofi::Payment"
  end
end
