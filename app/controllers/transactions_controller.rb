# frozen_string_literal: true

class TransactionsController < ApplicationController

  def predictum
    processor = TransactionProcessor.new(transaction_params)
    render json: { transaction_id: transaction_params[:transaction_id], recommendation: processor.process_predictum }
  end

  def predict
    processor = TransactionProcessor.new(transaction_params)
    render json: processor.process_predict
  end

  def predictcb
    processor = TransactionProcessor.new(transaction_params)
    render json: processor.process_predictcb
  end

  private

  def transaction_params
    params.permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount,
                  :device_id)
  end
end
