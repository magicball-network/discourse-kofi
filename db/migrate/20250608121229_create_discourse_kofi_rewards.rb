# frozen_string_literal: true

# rubocop:disable Discourse::NoAddReferenceOrAliasesActiveRecordMigration
class CreateDiscourseKofiRewards < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_kofi_rewards do |t|
      t.references :badge, foreign_key: true
      t.references :group, foreign_key: true

      t.boolean :subscription, null: false
      # If subscription
      t.string :tier_name

      # If not subscription
      t.string :payment_types, array: true
      t.decimal :amount, precision: 15, scale: 2

      t.timestamps
    end
  end
end
