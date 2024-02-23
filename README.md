   _____ _                 ___          __   _ _    
  / ____| |               | \ \        / /  | | |   
 | |    | | ___  _   _  __| |\ \  /\  / /_ _| | | __
 | |    | |/ _ \| | | |/ _` | \ \/  \/ / _` | | |/ /
 | |____| | (_) | |_| | (_| |  \  /\  / (_| | |   < 
  \_____|_|\___/ \__,_|\__,_|   \/  \/ \__,_|_|_|\_\
                                                    
                                                    
# CLOUDWALK

## Introduction

This Rails application is designed as a REST API to serve predictions, facilitating training machine learning models, employing a custom rule-based model for predictions, two machine learning models for predictions, and populating the database from a CSV file.

## Setup

Ensure Rails and Python are installed on your system. The application requires Python packages `xgboost` and `catboost` for machine learning model training.

pip install xgboost catboost

## Database Setup

Populate the default SQLite database with CSV data using:

rake db:populate

## Machine Learning Models Training

### Train two distinct machine learning models with the following commands:

    Train the first model (Rainforest) with:
        rake ml:train

    Train the second model (CatBoost) with:
        rake ml:traincb

Note: The second model (CatBoost) provides predictions in the form of a percentage chance of the transaction being fraudulent (and the comparator considers >0.75).


## Making Predictions

Send JSON data to one of these endpoints for predictions:

    For the first machine learning model (Rainforest) and the custom rule-based model:

POST /ml/transactions/predict
POST /um/transactions/predict

    For the second machine learning model (CatBoost):

POST /ml/transactions/predictcb

## JSON Payload

The expected JSON payload format for these endpoints is:

json

{
  "transaction_id": "123456",
  "merchant_id": "654321",
  "user_id": "112233",
  "card_number": "4444555566667777",
  "transaction_date": "2024-01-01T12:00:00",
  "transaction_amount": 100.50
}

## Response Formats

    The CatBoost model responds with a prediction as a percentage chance of fraud.
    The other models (Rainforest and the custom rule-based model) reply with a JSON object indicating a transaction recommendation:

        json

        { 
          "transaction_id": 2342357,
          "recommendation": "approve"
        }

## Python Comparator

    To compare predictions from both machine learning models and the custom rule-based model, run the comparator.py script located in /lib/python/:

        python3 lib/python/comparator.py

## Note
This is an API-focused application, emphasizing JSON request/response interactions for model interactions and database operations.

## Addendum
During my early stage of investigation, I developed some queries that helped me to make some inferences... they are here:


    Devices with most chargebacks:
        device_chargeback_counts = Transaction.where(has_cbk: true)
                                              .group(:device_id)
                                              .order('count_id DESC')
                                              .count('id')

        now showing to the total of transactions
        # Find devices with at least one chargeback, count chargebacks and total transactions
        device_stats = Device.joins(:transactions)
                             .select('devices.id, COUNT(transactions.id) AS total_transactions,
                                      SUM(CASE WHEN transactions.has_cbk THEN 1 ELSE 0 END) AS chargebacks_count')
                             .group('devices.id')
                             .having('SUM(CASE WHEN transactions.has_cbk THEN 1 ELSE 0 END) > 0')
                             .order('total_transactions DESC')
        device_stats_array = device_stats.map do |device|
          {
            device_id: device.id,
            total_transactions: device.total_transactions,
            chargebacks_count: device.chargebacks_count
          }
        end
        device_stats_array.each do |device_stat|
          puts "Device ID: #{device_stat[:device_id]}, Total Transactions: #{device_stat[:total_transactions]}, Chargebacks: #{device_stat[:chargebacks_count]}"
        end
        
Merchants with most transactions
    merchant_counts_by_device = Transaction.group(:merchant_id).count
    sorted_merchant_counts = merchant_counts_by_device.sort_by { |_merchant_id, count| -count }


Merchants with mos number of chargebacks and total of transactions
    merchant_stats = Merchant.joins(:transactions)
                             .select('merchants.id, COUNT(transactions.id) AS total_transactions,
                                      SUM(CASE WHEN transactions.has_cbk THEN 1 ELSE 0 END) AS chargebacks_count')
                             .group('merchants.id')
                             .having('SUM(CASE WHEN transactions.has_cbk THEN 1 ELSE 0 END) > 0')
                             .order('total_transactions DESC')
    merchant_stats_array = merchant_stats.map do |merchant|
      {
        merchant_id: merchant.id,
        total_transactions: merchant.total_transactions,
        chargebacks_count: merchant.chargebacks_count
      }
    end

    merchant_stats_array.each do |merchant_stat|
      puts "Merchant ID: #{merchant_stat[:merchant_id]}, Total Transactions: #{merchant_stat[:total_transactions]}, Chargebacks: #{merchant_stat[:chargebacks_count]}"
    end
