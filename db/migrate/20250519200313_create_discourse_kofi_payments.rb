# frozen_string_literal: true

# rubocop:disable Discourse::NoAddReferenceOrAliasesActiveRecordMigration
class CreateDiscourseKofiPayments < ActiveRecord::Migration[7.2]
  def change
    create_table :discourse_kofi_accounts do |t|
      t.string :email, null: false, index: { unique: true }
      t.references :user, null: false, index: true, foreign_key: true
      t.boolean :always_hide, null: false, default: false
      t.timestamps
    end

    create_table :discourse_kofi_payments do |t|
      t.string :message_id, null: false, index: { unique: true }
      t.datetime :timestamp, null: false, index: true
      t.string :type, null: false
      t.boolean :is_public, null: false
      t.string :from_name
      t.string :message
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :url
      t.string :email
      t.string :currency, null: false
      t.boolean :is_subscription_payment, null: false
      t.boolean :is_first_subscription_payment, null: false
      t.string :kofi_transaction_id, null: false, index: { unique: true }
      t.string :tier_name, index: { where: "tier_name is not null" }

      # Non-webhook fields
      t.string :payment_type, null: false, index: true

      t.references :account, foreign_key: { to_table: :discourse_kofi_accounts }
      t.references :user, index: true, foreign_key: true
      t.timestamps
    end
  end
end
