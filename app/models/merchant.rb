# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :transactions

  def self.verify_or_create_by_id(merchant_id)
    find_or_create_by(id: merchant_id)
  end

  def all_transactions_fraudulent?
    total_transactions = transactions.count
    fraudulent_transactions = transactions.where(has_cbk: true).count

    total_transactions.positive? && total_transactions == fraudulent_transactions
  end
end
