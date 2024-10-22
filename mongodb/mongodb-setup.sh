#!/bin/bash
# mongodb-setup.sh

# Create MongoDB database and collections
kubectl exec -it mongodb-pod -- mongosh --eval "
use scanners;
db.createCollection('findings');
"

echo "MongoDB database and collection created."
