import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import OrdinalEncoder
import joblib
import sys

# Load dataset
df = pd.read_csv(sys.argv[1], parse_dates=['transaction_date'])

# Handling 'device_id' null values by converting them to a specific marker (-999)
df['device_id_missing'] = df['device_id'].isnull().astype(int)
df['device_id'].fillna(-999, inplace=True)

# Assuming the operations to create 'transaction_amount_30_days', 'transaction_date_diff', 
# 'consecutive_transactions', 'has_previous_chargeback' are correctly implemented before this step.

# Check if columns exist before dropping to avoid KeyError
columns_to_drop = ['transaction_id', 'has_cbk', 'transaction_date', 'transaction_amount_30_days', 
                   'transaction_date_diff', 'consecutive_transactions', 'has_previous_chargeback']
columns_to_drop = [col for col in columns_to_drop if col in df.columns]
X = df.drop(columns_to_drop, axis=1)

# Prepare the data with Ordinal Encoding for categorical features
encoder = OrdinalEncoder(handle_unknown='use_encoded_value', unknown_value=-1)
features = ['merchant_id', 'user_id', 'transaction_amount', 'card_number', 'device_id', 'device_id_missing']
X[features] = encoder.fit_transform(X[features])

# Target variable
y = df['has_cbk'].astype(int)  # Ensure target variable is integer

# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the RandomForest model
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)

# Save the trained model and the encoder
joblib.dump(model, 'lib/models/trained_model.joblib')
joblib.dump(encoder, 'lib/models/encoder.joblib')
