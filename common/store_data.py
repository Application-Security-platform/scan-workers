import json
import pymongo
import os
from preprocess_data import preprocess_gitleaks, preprocess_semgrep
from multi_format_parser import ASTFingerprintParser

scanner_results_mapping = {
    "gitleaks":preprocess_gitleaks,
    # "trufflehog":preprocess_semgrep,
    "semgrep":preprocess_semgrep
}

def load_json(path):
    """Load JSON data from a file."""
    try:
        with open(path, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading JSON from {path}: {e}")
        return None


def store_in_mongodb(items):
    """Store the processed data in MongoDB."""
    mongo_uri = os.getenv("MONGODB_URI", "mongodb://mongodb-service:27017")
    client = pymongo.MongoClient(mongo_uri)
    db = client['scanners']
    collection = db['findings']
    if items:
        collection.insert_many(items)
    print("Data stored in MongoDB")


def assign_ast_fingerprint(items):
    for data in items:
        file_path = data.get('file_path')
        start_line=data.get('start_line')
        end_line= data.get('end_line')
        start_column=data.get('start_column')
        end_column= data.get('end_column')
        if file_path:
            print(f"{file_path=}")
            parser = ASTFingerprintParser(file_path)
            ast_fingerprint = parser.process_file_findings(start_line, end_line, start_column, end_column)
            
            data['ast_fingerprint'] = ast_fingerprint
        
    
    return items


def process_results(organization_id, repo_name):
    """Process all scanner results for a given repository."""
    results_dir = f"repo/{organization_id}/results/{repo_name}"
    print(f"{results_dir=}")
    if not os.path.exists(results_dir):
        print(f"Results directory {results_dir} does not exist.")
        return

    for filename in os.listdir(results_dir):
        print(f"{filename=}")
        file_path = os.path.join(results_dir, filename)
        if not filename.endswith(".json"):
            continue
        
        # Determine the scanner type based on the filename
        items = load_json(file_path)
        if items:
            scanner = scanner_results_mapping.get(filename.split("_")[0])
            if scanner:
                processed_data = scanner(items, organization_id, repo_name)
                processed_data_with_fingerprint = assign_ast_fingerprint(processed_data)
                store_in_mongodb(processed_data_with_fingerprint)
        
        else:
            print(f"Unknown scanner result file: {filename}")

def main():
    repo_name = os.getenv("REPO_NAME", "test_keys")
    organization_id = os.getenv("ORG_ID", "1611")
    print("started processing")
    process_results(organization_id, repo_name)

if __name__ == "__main__":
    main()