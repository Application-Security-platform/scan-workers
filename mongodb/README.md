# MongoDB Setup in Kubernetes

## Setup Instructions

### Step 1: Setup MongoDB Pod

1. **Apply the MongoDB Pod and Service Manifests**:
   In the `mongodb/` directory, you’ll find the YAML files for the MongoDB pod and service. Apply these files to create the MongoDB pod and service in your Kubernetes cluster:

   ```bash
   kubectl apply -f mongodb-setup.yaml
   ```
2. Set up MongoDB Database and Collection: Run the setup script to create the MongoDB database and required collections:
    ```bash
    ./mongodb-setup.sh
    ```


## Troubleshooting
### MongoDB Connection Issues
If you encounter issues connecting to MongoDB, ensure that the MongoDB service is running and the MONGODB_URI environment variable in the Gitleaks pod is correctly set to the MongoDB service name (mongodb-service:27017).

### DNS Resolution
Use nslookup or curl from inside the Gitleaks pod to verify connectivity to the MongoDB service.
    ```bash
    kubectl exec -it gitleaks-pod -- nslookup mongodb-service
    kubectl exec -it gitleaks-pod -- curl mongodb-service:27017
    ```

