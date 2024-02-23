import csv
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

def make_prediction_request(url, data, actual, model_name, results):
    """Make a POST request and update results based on the prediction accuracy."""
    try:
        response = requests.post(url, json=data)
        prediction_match = False  # Flag to track if the prediction matches the actual outcome

        if response.status_code == 200:
            if model_name == "CB":
                fraud_probability = float(response.text)  # Assuming the response is the fraud probability as a float
                recommendation = 'deny' if fraud_probability > 0.7 else 'approve'
                prediction_match = (fraud_probability > 0.7 and actual == 'deny') or (fraud_probability <= 0.7 and actual == 'approve')
                
                # Logging with indication of fraud probability
                print(f"{model_name} Prediction for Transaction ID {data['transaction_id']}: {recommendation} (Probability: {fraud_probability}), Actual: {actual}") 
            else:
                recommendation = response.json().get('recommendation')
                prediction_match = recommendation == actual
                print(f"{model_name} Prediction for Transaction ID {data['transaction_id']}: {recommendation}, Actual: {actual}")

            # Update results based on whether the prediction matches the actual outcome
            if prediction_match:
                results[model_name]['matches'] += 1
            else:
                results[model_name]['mismatches'] += 1
        else:
            print(f"Error for transaction {data['transaction_id']} on {model_name}: {response.status_code}")
    except Exception as e:
        print(f"Exception for transaction {data['transaction_id']} on {model_name}: {str(e)}")


def process_transactions(transaction):
    data, actual = transaction
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = [
            executor.submit(make_prediction_request, url_um, data, actual, 'UM', results),
            executor.submit(make_prediction_request, url_ml, data, actual, 'ML', results),
            executor.submit(make_prediction_request, url_cb, data, actual, 'CB', results)  # New fraud check
        ]
        for future in as_completed(futures):
            future.result()  # Wait for each request to complete and handle exceptions if any

# CSV file path
file_path = './bank.csv'

# URLs for the POST requests
url_um = 'http://localhost:3000/um/transactions/predict'
url_ml = 'http://localhost:3000/ml/transactions/predict'
url_cb = 'http://localhost:3000/ml/transactions/predictcb'  # URL for the new fraud check

# Store results
results = {
    'UM': {'matches': 0, 'mismatches': 0},
    'ML': {'matches': 0, 'mismatches': 0},
    'CB': {'matches': 0, 'mismatches': 0}  # Results for the new fraud check
}

transactions_to_process = []

with open(file_path, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        actual = 'approve' if row['has_cbk'].lower() == 'false' else 'deny'
        data = {
            "transaction_id": row["transaction_id"],
            "merchant_id": row["merchant_id"],
            "user_id": row["user_id"],
            "card_number": row["card_number"],
            "transaction_date": row["transaction_date"],
            "transaction_amount": row["transaction_amount"]
        }
        transactions_to_process.append((data, actual))

# Process transactions with multiple threads
with ThreadPoolExecutor(max_workers=30) as executor:
    executor.map(process_transactions, transactions_to_process)

# Summary
print(f"\nTotal Transactions Processed: {len(transactions_to_process)}")
for model_name, stats in results.items():
    print(f"{model_name}: Total Matches: {stats['matches']}, Total Mismatches: {stats['mismatches']}")
