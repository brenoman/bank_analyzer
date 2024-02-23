# frozen_string_literal: true

class PredictionController < ApplicationController
  skip_before_action :verify_authenticity_token

  def predict
    # Extract and sanitize input parameters
    sanitized_params = params.permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount, :device_id)
    
    # Verify or create the necessary records
    user = User.find_or_create_by(id: sanitized_params[:user_id])
    merchant = Merchant.find_or_create_by(id: sanitized_params[:merchant_id])
    
    # Find or create the CardNumber record. Adjust this part to correctly reference or create CardNumber records.
    card_number = CardNumber.find_or_create_by(card_number: sanitized_params[:card_number], user: user)
    
    device = Device.find_or_create_by(id: sanitized_params[:device_id]) if sanitized_params[:device_id].present?

    # Assuming Transaction model includes a reference to CardNumber model and optionally to Device
    transaction = Transaction.find_or_initialize_by(id: sanitized_params[:transaction_id]) do |t|
      t.user = user
      t.merchant = merchant
      t.card_number = card_number # This assumes the Transaction model references the CardNumber model directly
      t.transaction_date = sanitized_params[:transaction_date]
      t.transaction_amount = sanitized_params[:transaction_amount]
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

    # Proceed with fraud prediction
    service = FraudPredictionService.new(sanitized_params)
    prediction = service.predict

    result = if prediction.values.any?
               { transaction_id: sanitized_params[:transaction_id], recommendation: 'deny' }
             else
               { transaction_id: sanitized_params[:transaction_id], recommendation: 'approve' }
             end

    render json: result
  end
end
