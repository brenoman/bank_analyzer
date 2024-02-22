# frozen_string_literal: true

class CreateCardNumbers < ActiveRecord::Migration[7.0]
  def change
    create_table :card_numbers do |t|
      t.string :card_number
      t.integer :user_id

      t.timestamps
    end
    add_index :card_numbers, :user_id
  end
end
