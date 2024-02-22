# frozen_string_literal: true

class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wrap_parameters false

  def predict
    transaction_data = params.permit(:transaction_id, :has_cbk, :merchant_id, :user_id, :card_number,
                                     :transaction_date, :transaction_amount, :device_id)
    processed_data = TransactionDataPreprocessor.process(transaction_data.to_json)
    render json: processed_data
  end
end
