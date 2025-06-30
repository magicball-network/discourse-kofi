# frozen_string_literal: true

class AccountEmailHash < ActiveRecord::Migration[7.2]
  def change
    change_table :discourse_kofi_accounts, bulk: true do |t|
      t.string :email_hash, null: false
      t.boolean :anonymized, null: false, default: false
    end

    change_column_null :discourse_kofi_accounts, :user_id, true
    add_index :discourse_kofi_accounts, :email_hash, unique: true

    change_table :discourse_kofi_payments do |t|
      t.boolean :anonymized, null: false, default: false
    end
  end
end
