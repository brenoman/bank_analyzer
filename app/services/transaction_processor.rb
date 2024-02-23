# frozen_string_literal: true

class TransactionProcessor
  def initialize(params)
    @params = params
  end

  def process_predictum
    verify_and_register_entities
    FraudPredictionService.new(@params).predict
  end

  def process_predict
    verify_and_register_entities
    TransactionDataPreprocessor.process(@params.to_json)
  end

  def process_predictcb
    verify_and_register_entities
    TransactionDataPreprocessorCb.process(@params.to_json)
  end

  private

  def verify_and_register_entities
    user = User.verify_or_create_by_id(@params[:user_id])
    merchant = Merchant.verify_or_create_by_id(@params[:merchant_id])
    cardnumber = CardNumber.find_or_create_by_number_and_user(@params[:card_number], @user)
    device = Device.verify_or_create_by_id(@params[:device_id])

    Transaction.find_or_initialize_by(id: @params[:transaction_id]) do |t|
      t.assign_attributes(transaction_attributes(user, merchant))
      t.save unless t.persisted?
    end
  end

  def transaction_attributes(user, merchant, cardnumber, device)
    {
      user: user,
      merchant: merchant,
      card_number: cardnumber,
      transaction_date: @params[:transaction_date],
      transaction_amount: @params[:transaction_amount],
      device: device
    }
  end
end
