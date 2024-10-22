/app-security-platform
├── setup.py
├── scanners/
│   ├── gitleaks/
│   │   ├── Dockerfile
│   │   ├── entrypoint.sh
│   │   └── process_results.py
│   └── [other_scanner]/
│       ├── Dockerfile
│       ├── entrypoint.sh
│       └── process_results.py
├── kubernetes/
│   ├── gitleaks-deployment.yaml
│   └── [other_scanner]-deployment.yaml
└── database/
    └── init.sql