# frozen_string_literal: true

class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wrap_parameters false

  def predict
    verify_and_register(params)
    transaction_data = params.permit(:transaction_id, :has_cbk, :merchant_id, :user_id, :card_number,
                                     :transaction_date, :transaction_amount, :device_id)
    processed_data = TransactionDataPreprocessor.process(transaction_data.to_json)
    render json: processed_data
  end

  def predictcb
    verify_and_register(params)
    transaction_data = params.permit(:transaction_id, :has_cbk, :merchant_id, :user_id, :card_number,
                                     :transaction_date, :transaction_amount, :device_id)
    processed_data = TransactionDataPreprocessorCb.process(transaction_data.to_json)
    render json: processed_data
  end

  def verify_and_register(params)
    # Verify or create the necessary records
    user = User.find_or_create_by(id: params[:user_id])
    merchant = Merchant.find_or_create_by(id: params[:merchant_id])
    
    # Find or create the CardNumber record. Adjust this part to correctly reference or create CardNumber records.
    card_number = CardNumber.find_or_create_by(card_number: params[:card_number], user: user)
    
    device = Device.find_or_create_by(id: params[:device_id]) if params[:device_id].present?

    # Assuming Transaction model includes a reference to CardNumber model and optionally to Device
    transaction = Transaction.find_or_initialize_by(id: params[:transaction_id]) do |t|
      t.user = user
      t.merchant = merchant
      t.card_number = card_number # This assumes the Transaction model references the CardNumber model directly
      t.transaction_date = params[:transaction_date]
      t.transaction_amount = params[:transaction_amount]
      t.device = device if device.present?
    end

    # Save the transaction if it's a new record
    unless transaction.persisted?
      if transaction.save
        puts "New transaction created with ID: #{transaction.id}"
      else
        render json: transaction.errors, status: :unprocessable_entity
        return
      end
    end

  end
end
