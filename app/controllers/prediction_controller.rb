# frozen_string_literal: true

class PredictionController < ApplicationController
  skip_before_action :verify_authenticity_token
  def predict
    json_input = params.to_json
    data = JSON.parse(json_input)
    {
      cbk: verify_cbk(json_input),
      unusual_value: verify_value_pattern(json_input),
      rapid_transactions: verify_time_pattern(json_input),
      # Additional check for merchant with only fraudulent transactions
      suspicious_merchant: verify_merchant_suspicion(json_input)
    }
    unless [verify_cbk(json_input), verify_value_pattern(json_input), verify_time_pattern(json_input), verify_merchant_suspicion(json_input)].any?
      result = {
        transaction_id: data['transaction_id'],
        recommendation: 'approve'
      }
    else
      result = {
        transaction_id: data['transaction_id'],
        recommendation: 'deny'
      }
    end

    render json: result
  end

  def verify_value_pattern(json)
    # Assume json contains user_id and transaction_amount
    data = JSON.parse(json)
    begin
      user = User.find(data['user_id'])
    rescue ActiveRecord::RecordNotFound
      return false
    end

    average_past_amount = user.transactions.average(:transaction_amount) || 0
    amount_difference = (data['transaction_amount'].to_f - average_past_amount).abs

    # Define a threshold for what you consider a "big difference"
    threshold = 500 # Example threshold
    amount_difference > threshold
  end

  def verify_time_pattern(json)
    data = JSON.parse(json)
    begin
      user = User.find(data['user_id'])
    rescue ActiveRecord::RecordNotFound
      return false
    end

    last_transaction = user.transactions.order('transaction_date DESC').first
    return false unless last_transaction

    time_difference = Time.now - last_transaction.transaction_date
    # Check if the time difference is less than 5 minutes (300 seconds)
    time_difference < 300
  end

  def verify_cbk(json)
    data = JSON.parse(json)
    begin
      user = User.find(data['user_id'])
    rescue ActiveRecord::RecordNotFound
      return false
    end
    # Check if the user has any past transactions marked as cbk=true
    user.transactions.where(has_cbk: true).exists?
  end

  def verify_merchant_suspicion(json)
    data = JSON.parse(json)
    begin
      merchant = Merchant.find(data['merchant_id'])
    rescue ActiveRecord::RecordNotFound
      return false
    end
    
    # Check if all transactions for this merchant are fraudulent
    total_transactions = merchant.transactions.count
    fraudulent_transactions = merchant.transactions.where(has_cbk: true).count

    # Return true if all transactions are fraudulent, false otherwise
    total_transactions.positive? && total_transactions == fraudulent_transactions
  end
end
