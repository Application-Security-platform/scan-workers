#!/bin/bash
# gitleaks-run.sh

# Check if repository is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository_url>"
  exit 1
fi

REPO_URL=$1
WORK_DIR=/data/repo

# Create the WORK_DIR inside the pod if it doesn't exist
# kubectl exec -it gitleaks-pod -- mkdir -p $WORK_DIR

kubectl cp preprocess_and_store.py gitleaks-pod:/preprocess_and_store.py
kubectl cp requirements.txt gitleaks-pod:/requirements.txt


kubectl exec -it gitleaks-pod -- pip install -r requirements.txt
# Clone the repository inside the pod
kubectl exec -it gitleaks-pod -- git clone $REPO_URL $WORK_DIR

# Run Gitleaks inside the pod
kubectl exec -it gitleaks-pod -- gitleaks detect --source=$WORK_DIR --report-format=json --report-path=$WORK_DIR/gitleaks-report.json

# Run the Python script to preprocess and store in MongoDB inside the pod
kubectl exec -it gitleaks-pod -- python3 preprocess_and_store.py "$REPO_URL"

echo "Gitleaks scan completed, data preprocessed and stored in MongoDB."
