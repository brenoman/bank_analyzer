# frozen_string_literal: true

class AddCardNumberRefToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :card_number_id, :integer
    add_index :transactions, :card_number_id
  end
end
