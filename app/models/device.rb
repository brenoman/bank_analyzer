# frozen_string_literal: true

class Device < ApplicationRecord
  has_many :transactions
end
