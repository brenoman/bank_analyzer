# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    file_path = Rails.root.join('public', 'bank.csv') # Adjust the path as necessary
    data = SmarterCSV.process(file_path)
    @total_balance = data.sum { |row| row[:transaction_amount].to_f }
    @filtered_data = data
  end

  def user
    file_path = Rails.root.join('public', 'bank.csv') # Adjust the path as necessary
    data = SmarterCSV.process(file_path)
    @filtered_data = data.select { |row| row[:user_id].to_s == params[:id] }
  end

  def merchant
    file_path = Rails.root.join('public', 'bank.csv') # Adjust the path as necessary
    data = SmarterCSV.process(file_path)
    @total_balance = data.sum { |row| row[:transaction_amount].to_f }
    @filtered_data = data.select { |row| row[:merchant_id].to_s == params[:id] }
  end

  def device
    file_path = Rails.root.join('public', 'bank.csv') # Adjust the path as necessary
    data = SmarterCSV.process(file_path)
    @filtered_data = data.select { |row| row[:device_id].to_s == params[:id] }
    @filtered_data = @filtered_data.sort_by { |row| row[:card_number] }
  end
end
