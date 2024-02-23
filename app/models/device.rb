# frozen_string_literal: true

class Device < ApplicationRecord
  has_many :transactions

  def self.verify_or_create_by_id(device_id)
    find_or_create_by(id: device_id)
  end
end
