# frozen_string_literal: true

class PredictionController < ApplicationController
  skip_before_action :verify_authenticity_token
  def predict
    service = FraudPredictionService.new(params)
    prediction = service.predict

    unless prediction.values.any?
      result = { transaction_id: params['transaction_id'], recommendation: 'approve' }
    else
      result = { transaction_id: params['transaction_id'], recommendation: 'deny' }
    end

    render json: result
  end

end
