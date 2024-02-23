# frozen_string_literal: true

class CardNumber < ApplicationRecord
  belongs_to :user
  has_many :transactions
  validates :card_number, uniqueness: true, presence: true

  def self.find_or_create_by_number_and_user(card_number, user)
    find_or_create_by(card_number: card_number, user: user)
  end
end
