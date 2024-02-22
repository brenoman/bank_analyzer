# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :card_number
      t.datetime :transaction_date
      t.decimal :transaction_amount, precision: 10, scale: 2
      t.integer :device_id
      t.boolean :has_cbk

      t.timestamps
    end
  end
end
