## Setup Gitleaks Scanner Pod

1. Apply the Gitleaks Pod Manifest: In the gitleaks/ directory, you’ll find the YAML file for the Gitleaks pod. Apply this file to create the Gitleaks pod in your Kubernetes cluster:
```bash
kubectl apply -f gitleaks-pod.yaml
```

2. Run the Gitleaks Scanner: The gitleaks-run.sh script will clone the repository, run Gitleaks on it, and process the results. To run the scanner, use the following command with your desired repository URL:

```bash
./gitleaks-run.sh https://github.com/your-organization/your-repo.git
```