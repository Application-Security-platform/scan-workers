import os
import subprocess
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

def create_database():
    # Database connection parameters
    db_params = {
        "user": os.environ.get("DB_USER", "postgres"),
        "password": os.environ.get("DB_PASSWORD", "1234"),
        "host": os.environ.get("DB_HOST", "127.0.0.1"),
        "port": os.environ.get("DB_PORT", "5432")
    }

    db_name = os.environ.get("DB_NAME", "application_security")

    # Connect to PostgreSQL server
    conn = psycopg2.connect(**db_params)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()

    # Create database if it doesn't exist
    cur.execute(f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{db_name}'")
    exists = cur.fetchone()
    if not exists:
        cur.execute(f"CREATE DATABASE {db_name}")
        print(f"Database '{db_name}' created.")
    else:
        print(f"Database '{db_name}' already exists.")

    cur.close()
    conn.close()

    # Connect to the newly created database
    db_params["dbname"] = db_name
    conn = psycopg2.connect(**db_params)
    cur = conn.cursor()

    # Create tables
    ## Creating table Findings
    cur.execute("""
    CREATE TABLE IF NOT EXISTS Findings (
        id SERIAL PRIMARY KEY,
        organization_id VARCHAR(255),
        repository VARCHAR(255),
        source VARCHAR(50),
        description TEXT,
        finding VARCHAR(255),
        line INTEGER,
        entropy DECIMAL,
        secret TEXT,
        file TEXT,
        commit VARCHAR(255),
        author VARCHAR(255),
        email VARCHAR(255),
        date TIMESTAMP,
        message TEXT,
        rule_id VARCHAR(255),
        tags JSONB
    )
    """)

    # Add more table creations here as needed

    conn.commit()
    print("Tables created successfully.")

    cur.close()
    conn.close()

# Function to initialize resources like Docker containers, pods, etc.
def initialize_resources():
    print("Initializing resources...")

    # Start minikube or Kubernetes cluster
    subprocess.run(["minikube", "start"])

    # Apply necessary Kubernetes manifests (e.g., for PostgreSQL)
    subprocess.run(["kubectl", "apply", "-f", "k8s/postgres-deployment.yaml"])
    print("Kubernetes resources applied!")

def setup_other_resources():
    # Add code here to set up other required resources
    # For example, creating Kubernetes secrets, configmaps, etc.
    pass

if __name__ == "__main__":
    create_database()
    setup_other_resources()
    print("Setup completed successfully.")