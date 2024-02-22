# frozen_string_literal: true

require 'csv'

namespace :db do
  desc 'Populate the database using the csv file'
  task populate: :environment do
    file_path = Rails.root.join('lib', 'models', 'bank.csv').to_s
    CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
      merchant = Merchant.find_or_create_by(id: row[:merchant_id])
      user = User.find_or_create_by(id: row[:user_id])
      device = Device.find_or_create_by(id: row[:device_id]) if row[:device_id].present?
      card_number = CardNumber.find_or_create_by(card_number: row[:card_number], user: user)

      Transaction.create(
        merchant: merchant,
        user: user,
        card_number: card_number,
        transaction_date: row[:transaction_date],
        transaction_amount: row[:transaction_amount],
        device: device,
        has_cbk: row[:has_cbk].casecmp('TRUE').zero?
      )
    end
    puts 'Database populated.'
  end
end
