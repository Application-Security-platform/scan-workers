## Table of Contents
- [Project Structure](#project-structure)

## Project Structure

```bash
project-root/
├── mongodb/
│   ├── mongodb-pod.yaml          # MongoDB pod definition
│   ├── mongodb-service.yaml       # MongoDB service definition
│   └── mongodb-setup.sh           # Script to set up MongoDB database and collections
│
├── scanners/
│   ├── gitleaks # gitleaks scanner    
│       ├── gitleaks-pod.yaml          # Gitleaks pod definition
│       ├── gitleaks-run.sh            # Script to run Gitleaks scanner and process the results
│       ├── preprocess_and_store.py    # Python script for preprocessing Gitleaks data and storing in 
│       └── README.md                  # Gitleaks-specific instructions
│   ├── trufflehog # gitleaks scanner    
│       ├── trufflehog-pod.yaml          # trufflehog pod definition
│       ├── trufflehog-run.sh            # Script to run trufflehog scanner and process the results
│       ├── preprocess_and_store.py    # Python script for preprocessing trufflehog data and storing in 
│       └── README.md                  # trufflehog-specific instructions
│
└── README.md                      # Root README file
```

## Setup Instructions

### Step 1: Setup MongoDB Pod

1. **Apply the MongoDB Pod and Service Manifests**:
   In the `mongodb/` directory, you’ll find the YAML files for the MongoDB pod and service. Apply these files to create the MongoDB pod and service in your Kubernetes cluster:

   ```bash
   kubectl apply -f mongodb/mongodb-setup.yaml
   ```
2. Set up MongoDB Database and Collection: Run the setup script to create the MongoDB database and required collections:
    ```bash
    ./mongodb/mongodb-setup.sh
    ```


## Troubleshooting
### MongoDB Connection Issues
If you encounter issues connecting to MongoDB, ensure that the MongoDB service is running and the MONGODB_URI environment variable in the scanner pods is correctly set to the MongoDB service name (mongodb-service:27017).

### DNS Resolution
Use nslookup or curl from inside the scanner pod to verify connectivity to the MongoDB service.
    ```bash
    kubectl exec -it scanner-pod -- nslookup mongodb-service
    kubectl exec -it scanner-pod -- curl mongodb-service:27017
    ```
