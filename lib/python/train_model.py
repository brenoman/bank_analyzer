import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OrdinalEncoder
import joblib
import sys

# Load dataset
df = pd.read_csv(sys.argv[1])

# Handling 'device_id' null values by converting them to a specific marker (-999)
df['device_id_missing'] = df['device_id'].isnull().astype(int)
df['device_id'].fillna(-999, inplace=True)

# Remove transactions above a certain amount in a given period
# Assuming the threshold is $5000 and the period is 30 days
max_amount_threshold = 5000
period_days = 30  # This should be an integer value
df['transaction_date'] = pd.to_datetime(df['transaction_date'])
df['transaction_amount_30_days'] = df.groupby('user_id')['transaction_amount'].rolling(window=period_days, min_periods=1).sum().reset_index(drop=True)
df = df[df['transaction_amount_30_days'] <= max_amount_threshold]

# Exclude transactions from users with recent consecutive transactions
max_consecutive_transactions = 5
df['transaction_date_diff'] = df.groupby('user_id')['transaction_date'].diff().dt.days
df['consecutive_transactions'] = df.groupby('user_id')['transaction_date_diff'].transform(lambda x: x.lt(2).cumsum())
df = df[df['consecutive_transactions'] <= max_consecutive_transactions]

# Identify users with previous chargebacks based on transaction history
df['has_previous_chargeback'] = df.groupby('user_id')['has_cbk'].transform(lambda x: x.shift().fillna(0).cumsum() > 0)

# Prepare the data with Ordinal Encoding for categorical features
encoder = OrdinalEncoder(handle_unknown='use_encoded_value', unknown_value=-1)
features = ['user_id', 'merchant_id', 'transaction_amount', 'card_number', 'device_id', 'device_id_missing']
df[features] = encoder.fit_transform(df[features])

# Target variable
y = df['has_cbk']
X = df.drop(['transaction_id', 'has_cbk', 'transaction_date', 'transaction_amount_30_days', 'transaction_date_diff', 'consecutive_transactions', 'has_previous_chargeback'], axis=1)

# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the RandomForest model
model = RandomForestClassifier(random_state=42)
model.fit(X_train, y_train)

# Save the trained model and the encoder
joblib.dump(model, 'lib/models/trained_model.joblib')
joblib.dump(encoder, 'lib/models/encoder.joblib')
