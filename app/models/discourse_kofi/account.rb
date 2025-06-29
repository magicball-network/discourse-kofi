# frozen_string_literal: true

module ::DiscourseKofi
  class Account < ActiveRecord::Base
    self.table_name = "discourse_kofi_accounts"

    belongs_to :user
    has_many :payments, class_name: "DiscourseKofi::Payment"
  end
end

# == Schema Information
#
# Table name: discourse_kofi_accounts
#
#  id          :bigint           not null, primary key
#  email       :string           not null
#  user_id     :bigint           not null
#  always_hide :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_discourse_kofi_accounts_on_email    (email) UNIQUE
#  index_discourse_kofi_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
