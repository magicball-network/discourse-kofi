# frozen_string_literal: true

# rubocop:disable Discourse::NoAddReferenceOrAliasesActiveRecordMigration
class CreateDiscourseKofiSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_kofi_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reward,
                   null: false,
                   foreign_key: {
                     to_table: :discourse_kofi_rewards
                   }
      t.references :last_payment,
                   null: false,
                   foreign_key: {
                     to_table: :discourse_kofi_payments
                   }

      # Used during reprocessing when the reward was changed
      t.string :tier_name, null: false
      t.references :group, null: false, foreign_key: true

      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
