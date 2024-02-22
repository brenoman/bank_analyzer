import pandas as pd
import joblib
import json
import sys

# Load the trained model and encoder
model = joblib.load('lib/models/trained_model.joblib')
encoder = joblib.load('lib/models/encoder.joblib')

def preprocess(transaction_json):
    # Parse the transaction data from JSON
    transaction_data = json.loads(transaction_json)
    df = pd.DataFrame([transaction_data])

    # Handling 'device_id' null values by assigning a specific marker (-999) and creating a 'device_id_missing' flag
    print("Missing "+str(df['device_id']))
    df['device_id_missing'] = df['device_id'].isnull().astype(int)
    df['device_id'].fillna(-999, inplace=True)

    # Encode categorical features
    features = ['merchant_id', 'user_id', 'transaction_amount', 'card_number', 'device_id', 'device_id_missing']
    df[features] = encoder.transform(df[features])

    # Exclude non-used fields. Assuming transaction_date and transaction_id are not used in the prediction model
    df.drop(['transaction_id', 'transaction_date'], axis=1, inplace=True, errors='ignore')

    return df

if __name__ == '__main__':
    transaction_json = sys.argv[1]
    preprocessed_df = preprocess(transaction_json)
    # Predicting the probability of fraud (class 1)
    probability = model.predict_proba(preprocessed_df)[:, 1]

    # You can adjust this threshold based on your risk tolerance
    fraud_threshold = 0.5
    decision = "approve" if probability[0] < fraud_threshold else "deny"

    # Extracting transaction_id for the response
    final = json.loads(transaction_json)
    print(json.dumps({'transaction_id': str(final["transaction_id"]), 'recommendation': decision}))
