# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :merchant
  belongs_to :user
  belongs_to :device, optional: true
  belongs_to :card_number
end
