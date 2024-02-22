# frozen_string_literal: true

class CreateMerchants < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants, &:timestamps
  end
end
