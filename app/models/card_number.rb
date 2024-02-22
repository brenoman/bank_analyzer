# frozen_string_literal: true

class CardNumber < ApplicationRecord
  belongs_to :user
  has_many :transactions
  validates :card_number, uniqueness: true
end
