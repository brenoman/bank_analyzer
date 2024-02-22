# frozen_string_literal: true

class User < ApplicationRecord
  has_many :transactions

  def has_recent_rapid_transaction?
    last_transaction = transactions.order('transaction_date DESC').first
    return false unless last_transaction

    (Time.now - last_transaction.transaction_date) < 300
  end

  def has_cbk_transactions?
    transactions.where(has_cbk: true).exists?
  end
end
