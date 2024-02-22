import csv
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

def make_prediction_request(url, data, actual, model_name, results):
    """Make a POST request and update results based on the prediction accuracy."""
    try:
        response = requests.post(url, json=data)
        if response.status_code == 200:
            recommendation = response.json().get('recommendation')
            print(f"{model_name} Prediction for Transaction ID {data['transaction_id']}: {recommendation}, Actual: {actual}")
            
            if recommendation == actual:
                results[model_name]['matches'] += 1
            else:
                results[model_name]['mismatches'] += 1
        else:
            print(f"Error for transaction {data['transaction_id']} on {model_name}: {response.status_code}")
    except Exception as e:
        print(f"Exception for transaction {data['transaction_id']} on {model_name}: {str(e)}")

def process_transactions(transaction):
    data, actual = transaction
    with ThreadPoolExecutor(max_workers=2) as executor:
        futures = [
            executor.submit(make_prediction_request, url_um, data, actual, 'UM', results),
            executor.submit(make_prediction_request, url_ml, data, actual, 'ML', results)
        ]
        for future in as_completed(futures):
            future.result()  # Wait for each request to complete and handle exceptions if any

# CSV file path
file_path = './bank.csv'

# URLs for the POST requests
url_um = 'http://localhost:3000/um/transactions/predict'
url_ml = 'http://localhost:3000/ml/transactions/predict'

# Store results
results = {
    'UM': {'matches': 0, 'mismatches': 0},
    'ML': {'matches': 0, 'mismatches': 0}
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

# Process transactions with 30 threads
with ThreadPoolExecutor(max_workers=30) as executor:
    executor.map(process_transactions, transactions_to_process)

# Summary
print(f"\nTotal Transactions Processed: {len(transactions_to_process)}")
print("UM: Total Matches: {matches}, Total Mismatches: {mismatches}".format(**results['UM']))
print("ML: Total Matches: {matches}, Total Mismatches: {mismatches}".format(**results['ML']))

