REPO_URL=$1
ORG_ID=$2
REPO_NAME=$(basename -s .git "$REPO_URL")
CLONE_PATH="/mnt/data/repo/$ORG_ID/$REPO_NAME"

# Ensure the CLONE_PATH directory exists in the pod
kubectl exec -it repo-clone-pod -- mkdir -p "$CLONE_PATH"

# Remove contents of the directory, without touching system directories
kubectl exec -it repo-clone-pod -- bash -c "if [ -d '$CLONE_PATH' ]; then rm -rf '$CLONE_PATH'/*; fi"

# Clone the repository inside the pod
kubectl exec -it repo-clone-pod -- git clone "$REPO_URL" "$CLONE_PATH"
