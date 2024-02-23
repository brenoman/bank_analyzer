import pandas as pd
from catboost import CatBoostClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score
import sys

# Load the dataset
df = pd.read_csv(sys.argv[1])

# Preprocess the data
## Convert 'transaction_date' to datetime
df['transaction_date'] = pd.to_datetime(df['transaction_date'])

## Extract day of week and hour of day from 'transaction_date'
df['day_of_week'] = df['transaction_date'].dt.dayofweek
df['hour_of_day'] = df['transaction_date'].dt.hour

## Handle missing values for 'device_id'
df['device_id'].fillna('unknown', inplace=True)

## Convert categorical features to strings
cat_features = ['merchant_id', 'user_id', 'card_number', 'device_id']
for feature in cat_features:
    df[feature] = df[feature].astype(str)

## Define the target variable based on 'has_cbk' column, converting boolean to integer
df['is_fraud'] = df['has_cbk'].apply(lambda x: 1 if x else 0)

# Check the distribution of 'is_fraud' to confirm two unique values
print("Distribution of 'is_fraud':")
print(df['is_fraud'].value_counts())

# Ensure the target variable contains more than one unique value
if df['is_fraud'].nunique() < 2:
    raise ValueError("The target variable contains less than 2 unique values, cannot proceed with training.")

# Select features and target, excluding direct identifiers and non-predictive information
X = df.drop(['transaction_id', 'has_cbk', 'is_fraud', 'transaction_date'], axis=1)
y = df['is_fraud']

# Stratified splitting of the dataset into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# Training the CatBoostClassifier
model = CatBoostClassifier(
    iterations=300,
    learning_rate=0.1,
    depth=6,
    verbose=50,
    cat_features=cat_features,
    eval_metric='AUC'
)
model.fit(X_train, y_train, eval_set=(X_test, y_test))

# Predict and evaluate using AUC-ROC
y_pred_prob = model.predict_proba(X_test)[:, 1]
auc_roc = roc_auc_score(y_test, y_pred_prob)
print(f'AUC-ROC: {auc_roc}')

# Save the model to a file
model.save_model('lib/models/fraud_detection_model.cbm')
