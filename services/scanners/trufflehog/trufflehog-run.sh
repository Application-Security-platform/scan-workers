#!/bin/bash
# trufflehog-run.sh

# Check if repository URL is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository_url> <org_id>"
  exit 1
fi

REPO_URL=$1
ORG_ID=$2
REPO_NAME=$(basename -s .git "$REPO_URL")
CLONE_PATH="/mnt/data/repo/$ORG_ID/$REPO_NAME"
TRUFFLEHOG_REPORT_PATH="$CLONE_PATH/trufflehog-result.json"

# Copy the necessary Python script and requirements into the pod
kubectl cp preprocess_and_store.py trufflehog-pod:/preprocess_and_store.py
kubectl cp requirements.txt trufflehog-pod:/requirements.txt

# Install requirements in the pod
kubectl exec -it trufflehog-pod -- pip install --root-user-action=ignore -r requirements.txt

# # Ensure the CLONE_PATH directory exists in the pod
# kubectl exec -it trufflehog-pod -- mkdir -p /data/repo/$ORG_ID

# # Fully remove the old CLONE_PATH to avoid git clone conflicts
# kubectl exec -it trufflehog-pod -- rm -rf "$CLONE_PATH"

# # Recreate the CLONE_PATH directory
# kubectl exec -it trufflehog-pod -- mkdir -p "$CLONE_PATH"

# # Clone the repository inside the pod
# kubectl exec -it trufflehog-pod -- git clone "$REPO_URL" "$CLONE_PATH"

# Run trufflehog inside the pod (correctly expanding variables)
kubectl exec -it trufflehog-pod -- sh -c "trufflehog filesystem '$CLONE_PATH' --only-verified --no-update --json > '$TRUFFLEHOG_REPORT_PATH'"

# Run the Python script to preprocess and store in MongoDB inside the pod
kubectl exec -it trufflehog-pod -- python3 preprocess_and_store.py "$REPO_URL" "$ORG_ID" "$TRUFFLEHOG_REPORT_PATH"

echo "Trufflehog scan completed, data preprocessed, and stored in MongoDB."
