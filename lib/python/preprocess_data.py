import pandas as pd
import joblib
import json
import sys

# Load the trained encoder
model = joblib.load('lib/models/trained_model.joblib')
encoder = joblib.load('lib/models/encoder.joblib')

def preprocess(transaction_json):
    # Parse the transaction data from JSON
    transaction_data = json.loads(transaction_json)
    df = pd.DataFrame([transaction_data])

    # Ensure 'device_id' is included with a default value if missing
    if 'device_id' not in df.columns or pd.isnull(df['device_id']).any():
        df['device_id'] = df.get('device_id', pd.Series([-999]))
        df['device_id_missing'] = 1
    else:
        df['device_id_missing'] = df['device_id'].isnull().astype(int)
        df['device_id'].fillna(-999, inplace=True)

    # Encode features
    features = ['user_id', 'merchant_id', 'transaction_amount', 'card_number', 'device_id', 'device_id_missing']
    df[features] = encoder.transform(df[features])

    # Exclude non-used fields
    df.drop(['transaction_id', 'transaction_date'], axis=1, inplace=True, errors='ignore')
    
    return df


if __name__ == '__main__':
    transaction_json = sys.argv[1]
    preprocessed_df = preprocess(transaction_json)
    prediction = model.predict(preprocessed_df)
    final = json.loads(transaction_json)
    if int(prediction[0]) == 0:
        recommendation = "approve"
    else:
        recommendation = "deny"
    print(json.dumps({'transaction_id': str(final["transaction_id"]), 'recommendation': recommendation}))
