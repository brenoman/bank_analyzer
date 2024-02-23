import pandas as pd
import json
import sys
from datetime import datetime
from catboost import CatBoostClassifier

# Assuming this is the path where the trained CatBoost model is saved.
MODEL_PATH = 'lib/models/fraud_detection_model.cbm'

# Load the trained CatBoost model.
model = CatBoostClassifier()
model.load_model(MODEL_PATH)

def parse_json(transaction_json):
    transaction_data = json.loads(transaction_json)
    return pd.DataFrame([transaction_data])

def handle_missing_values(df):
    expected_columns = ['merchant_id', 'user_id', 'card_number', 'transaction_amount', 'device_id']
    for col in expected_columns:
        if col not in df.columns:
            df[col] = 'unknown' if col != 'transaction_amount' else 0  # Default values
        elif pd.isnull(df[col]).any():
            df[col].fillna('unknown' if col != 'transaction_amount' else 0, inplace=True)
    return df

def feature_engineering(df):
    # Convert 'transaction_date' to datetime and extract 'day_of_week' and 'hour_of_day'
    df['transaction_date'] = pd.to_datetime(df['transaction_date'])
    df['day_of_week'] = df['transaction_date'].dt.dayofweek
    df['hour_of_day'] = df['transaction_date'].dt.hour
    return df

def preprocess_features(df):
    # Convert all features to string to match CatBoost expectations for categorical data
    for col in df.columns:
        if col not in ['transaction_amount']:  # Assuming 'transaction_amount' is numeric
            df[col] = df[col].astype(str)
    return df

def predict(df):
    # Select and reorder the columns as per the model's training data
    features_for_model = ['merchant_id', 'user_id', 'card_number', 'transaction_amount', 'device_id', 'day_of_week', 'hour_of_day']
    df_for_prediction = df[features_for_model]
    probabilities = model.predict_proba(df_for_prediction)
    return probabilities[:, 1]

def main(transaction_json):
    df = parse_json(transaction_json)
    df = handle_missing_values(df)
    df = feature_engineering(df)
    df = preprocess_features(df)
    fraud_probability = predict(df)
    print(str(float(fraud_probability[0])))
#    result = {
 #       'transaction_id': str(df.at[0, "transaction_id"]),
  #      'fraud_probability': float(fraud_probability[0])
   # }
    #print(json.dumps(result))

if __name__ == '__main__':
    transaction_json = sys.argv[1]  # Adjusted for direct command line argument
    main(transaction_json)
