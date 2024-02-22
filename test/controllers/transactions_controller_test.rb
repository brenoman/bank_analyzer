# frozen_string_literal: true

require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get analyze' do
    get transactions_analyze_url
    assert_response :success
  end
end
