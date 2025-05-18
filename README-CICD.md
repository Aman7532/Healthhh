# Healthcare Chatbot CI/CD Pipeline

This document explains the CI/CD pipeline setup for the RAG-based Healthcare Chatbot project.

## Pipeline Overview

The CI/CD pipeline automates the entire process from code checkout to deployment using Jenkins. The pipeline is defined in the `Jenkinsfile` and includes the following stages:

1. **Checkout SCM**: Retrieves the latest code from the source control management system.
2. **Setup Python Environment**: Creates a virtual environment and installs all required dependencies.
3. **Download NLTK Data**: Downloads necessary NLTK data for natural language processing.
4. **Run Tests**: Executes unit and integration tests to ensure code quality.
5. **Debug Docker**: Collects Docker system information for debugging purposes.
6. **Build Docker Image**: Builds the Docker image for the Healthcare Chatbot application.
7. **Push Docker Images**: Pushes the Docker images to Docker Hub with appropriate tags.
8. **Prepare Ansible Environment**: Sets up the Ansible environment for deployment.
9. **Run Ansible Playbook**: Executes the Ansible playbook to deploy the application to Kubernetes.
10. **Verify Deployment**: Checks the status of the deployed application in Kubernetes.
11. **Setup Monitoring**: Configures basic monitoring for the application.

## Prerequisites

To run the CI/CD pipeline, you need:

1. Jenkins server with the following plugins:
   - Pipeline
   - Docker Pipeline
   - Credentials Binding
   - Kubernetes CLI

2. Jenkins credentials:
   - `docker-hub-credentials`: Docker Hub credentials for pushing images
   - `kubeconfig`: Kubernetes configuration file for deploying to the cluster
   - `google-api-key`: Google API key for the Gemini AI service

3. Jenkins tools configuration:
   - Maven
   - JDK 11
   - Python 3

## Deployment Methods

The project supports three deployment methods:

### 1. Local Development

Run the application locally for development purposes:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirement.txt
python chatpdf1.py
```

Access the application at http://localhost:3000

### 2. Docker Compose

Deploy using Docker Compose for a containerized environment:

```bash
docker-compose -f docker-compose-app-only.yml up -d
```

Access the application at http://localhost:3000

### 3. Kubernetes

Deploy to a Kubernetes cluster using Ansible:

```bash
export KUBECONFIG=~/.kube/config
export GOOGLE_API_KEY=your-api-key
ansible-playbook ansible-deploy-app-only.yml -v
```

Access the application by port-forwarding:

```bash
kubectl port-forward -n healthcare-chatbot svc/healthcare-chatbot-service 8090:80
```

Then access at http://localhost:8090

## Architecture

The Healthcare Chatbot application consists of:

1. **Flask Backend**: Handles API requests and serves the web interface
2. **RAG System**: Retrieves relevant information from the knowledge base
3. **ExtraTrees Model**: Predicts diseases based on symptoms
4. **Kubernetes Deployment**: Manages the application containers
5. **CI/CD Pipeline**: Automates the build and deployment process

## Monitoring and Logging

The full deployment includes an ELK stack (Elasticsearch, Logstash, Kibana) for monitoring and logging, which can be enabled by using the complete Ansible playbook:

```bash
ansible-playbook ansible-deploy.yml -v
```

## Future Enhancements

1. Add automated performance testing
2. Implement blue-green deployment strategy
3. Add security scanning for Docker images
4. Implement automated rollback on deployment failure
5. Add more comprehensive monitoring with Prometheus and Grafana
