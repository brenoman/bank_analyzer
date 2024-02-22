# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :transactions

  def all_transactions_fraudulent?
    total_transactions = transactions.count
    fraudulent_transactions = transactions.where(has_cbk: true).count

    total_transactions.positive? && total_transactions == fraudulent_transactions
  end
end
