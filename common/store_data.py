import json
import pymongo
import os
from preprocess_data import preprocess_gitleaks, preprocess_semgrep, preprocess_trufflehog

scanner_results_mapping = {
    "gitleaks":preprocess_gitleaks,
    "trufflehog":preprocess_semgrep,
    "semgrep":preprocess_trufflehog
}

def load_json(path):
    """Load JSON data from a file."""
    try:
        with open(path, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading JSON from {path}: {e}")
        return None


def store_in_mongodb(data):
    """Store the processed data in MongoDB."""
    mongo_uri = os.getenv("MONGODB_URI", "mongodb://mongodb-service:27017")
    client = pymongo.MongoClient(mongo_uri)
    db = client['scanners']
    collection = db['findings']
    if data:
        collection.insert_many(data)
    print("Data stored in MongoDB")


def process_results(organization_id, repo_name):
    """Process all scanner results for a given repository."""
    results_dir = f"repo/{organization_id}/results/{repo_name}"
    if not os.path.exists(results_dir):
        print(f"Results directory {results_dir} does not exist.")
        return

    for filename in os.listdir(results_dir):
        file_path = os.path.join(results_dir, filename)
        if not filename.endswith(".json"):
            continue
        
        # Determine the scanner type based on the filename
        data = load_json(file_path)
        if data:
            scanner = scanner_results_mapping.get(filename.split("-")[0])
            if scanner:
                processed_data = scanner(data, organization_id, repo_name)
                store_in_mongodb(processed_data)
        
        else:
            print(f"Unknown scanner result file: {filename}")

def main():
    repo_name = os.getenv("REPO_NAME", "test_keys")
    organization_id = os.getenv("ORG_ID", "1611")
    process_results(organization_id, repo_name)

if __name__ == "__main__":
    main()