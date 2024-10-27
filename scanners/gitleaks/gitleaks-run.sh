#!/bin/bash
# gitleaks-run.sh

# Check if repository is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository_url> <org_id>"
  exit 1
fi

REPO_URL=$1
ORG_ID=$2
REPO_NAME=$(basename -s .git "$REPO_URL")
CLONE_PATH="/mnt/data/repo/$ORG_ID/$REPO_NAME"
GITLEAKS_REPORT_PATH="$CLONE_PATH/gitleaks-result.json"

# Copy necessary files to the pod
kubectl cp preprocess_and_store.py gitleaks-pod:/preprocess_and_store.py
kubectl cp requirements.txt gitleaks-pod:/requirements.txt

# Install dependencies in the pod
kubectl exec -it gitleaks-pod -- pip install -r requirements.txt

# # Ensure the CLONE_PATH directory exists in the pod
# kubectl exec -it gitleaks-pod -- mkdir -p "$CLONE_PATH"

# # Remove contents of the directory, without touching system directories
# kubectl exec -it gitleaks-pod -- bash -c "if [ -d '$CLONE_PATH' ]; then rm -rf '$CLONE_PATH'/*; fi"

# # Clone the repository inside the pod
# kubectl exec -it gitleaks-pod -- git clone "$REPO_URL" "$CLONE_PATH"

# Run Gitleaks inside the pod
kubectl exec -it gitleaks-pod -- gitleaks detect --source="$CLONE_PATH" --report-format=json --report-path="$GITLEAKS_REPORT_PATH"

# Run the Python script to preprocess and store in MongoDB inside the pod
kubectl exec -it gitleaks-pod -- python3 preprocess_and_store.py "$REPO_URL" "$ORG_ID" "$GITLEAKS_REPORT_PATH"

echo "Gitleaks scan completed, data preprocessed and stored in MongoDB."
