# preprocess_and_store.py
import json
import pymongo
import os
import sys

# MongoDB connection setup
MONGO_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
client = pymongo.MongoClient(MONGO_URI)
db = client['scanners']
collection = db['findings']

# Path to the Trufflehog JSON report
# TRUFFLEHOG_REPORT_PATH = "data/repo/trufflehog-report.json"
'''
temp={
            "description": entry.get('Description'),
            "start_line":entry.get('StartLine'),
            "end_line": entry.get('EndLine'),
            "start_column":entry.get('StartColumn'),
            "end_column": entry.get('EndColumn'),
            "match":entry.get('Match'),
            "secret":entry.get('Secret'),
            "file": entry.get('File'),
            "symlink_file":entry.get('SymlinkFile'),
            "commit": entry.get('Commit'),
            "entropy":entry.get('Entropy'),
            "author":entry.get('Author'),
            "email": entry.get('Email'),
            "date":entry.get('Date'),
            "message":entry.get('Message'),
            "tags": entry.get('Tags'),
            "rule_id":entry.get('RuleID'),
            "fingerprint": entry.get('Fingerprint'),
        }
'''
def preprocess_data(report_data, repo_url, organization_id):
    """Preprocess the data from Trufflehog report."""
    processed_data = []
    for entry in report_data:
        # For example, we can filter out any low-severity findings
        processed_data.append({
            "organization_id": organization_id,
            "repo_name":repo_url.replace(".git", ""),
            "source":"osint",
            "scanner_source":"trufflehog",
            **entry
        })
    return processed_data


def load_report(path):
    """Load the Trufflehog report from a JSON file (NDJSON format)."""
    try:
        report_data = []
        with open(path, 'r') as f:
            for line in f:
                report_data.append(json.loads(line))
        return report_data
    except Exception as e:
        print(f"Error loading report: {e}")
        return []


def store_in_mongodb(data):
    """Store the preprocessed data into MongoDB."""
    if data:
        result = collection.insert_many(data)
        print(f"Inserted {len(result.inserted_ids)} records into MongoDB.")
    else:
        print("No data to insert into MongoDB.")

def main():
    if len(sys.argv) > 1:
        repo_url = sys.argv[1]
        organization_id = sys.argv[2]
        TRUFFLEHOG_REPORT_PATH = sys.argv[3]
    else:
        print("Provide Repository URL")
        return

    # Load the Gitleaks report
    report_data = load_report(TRUFFLEHOG_REPORT_PATH)

    # Preprocess the data
    processed_data = preprocess_data(report_data, repo_url, organization_id)

    # Store the processed data in MongoDB
    store_in_mongodb(processed_data)

if __name__ == "__main__":
    main()
