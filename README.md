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

Note: The second model (CatBoost) provides predictions in the form of a percentage chance of the transaction being fraudulent.


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
