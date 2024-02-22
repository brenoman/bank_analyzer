# frozen_string_literal: true

class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  wrap_parameters false

  def predict
    transaction_data = params.permit(:transaction, :transaction_id, :has_cbk, :merchant_id, :user_id, :card_number,
                                     :transaction_date, :transaction_amount, :device_id)
    transaction_data = transaction_data.to_json
    processed_data = preprocess_data(transaction_data)
    render json: processed_data
  end

  private

  def preprocess_data(data)
    output = `python3 lib/python/preprocess_data.py '#{data}'`
    JSON.parse(output)
  rescue JSON::ParserError => e
    { error: "Failed to parse JSON from Python script: #{e.message}" }
  end
end
