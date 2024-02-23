# frozen_string_literal: true

class FraudPredictionService
  def initialize(params)
    @params = params
  end

  def predict
    prediction_checks = {
      cbk: User.find(@params['user_id']).has_cbk_transactions?,
      unusual_value: verify_value_pattern,
      rapid_transactions: User.find(@params['user_id']).has_recent_rapid_transaction?,
      suspicious_merchant: Merchant.find(@params['merchant_id']).all_transactions_fraudulent?
    }
    prediction_checks.values.any? ? 'deny' : 'approve'
  end

  private

  def verify_value_pattern
    user = User.find(@params['user_id'])
    average_past_amount = user.transactions.average(:transaction_amount) || 0
    amount_difference = (@params['transaction_amount'].to_f - average_past_amount).abs
    threshold = 500
    amount_difference > threshold
  end
end
