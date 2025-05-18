# Jenkins Setup Guide for Healthcare Chatbot Project

This guide will help you set up Jenkins properly for your Healthcare Chatbot CI/CD pipeline.

## 1. Jenkins Installation and Initial Setup

If you haven't already installed Jenkins, you can do so using:

```bash
brew install jenkins-lts
```

Start Jenkins:

```bash
brew services start jenkins-lts
```

Access Jenkins at http://localhost:8080 and complete the initial setup.

## 2. Required Jenkins Plugins

Ensure you have these plugins installed (Manage Jenkins > Plugins > Available):

- Pipeline
- Docker Pipeline
- Credentials Binding
- Kubernetes CLI
- Git Integration
- AnsiColor (for better console output)

## 3. Setting Up Required Credentials

Go to Manage Jenkins > Credentials > System > Global credentials and add:

1. **Docker Hub Credentials**
   - Kind: Username with password
   - ID: `docker-hub-credentials`
   - Username: `aman7532`
   - Password: Your Docker Hub password

2. **Google API Key**
   - Kind: Secret text
   - ID: `google-api-key`
   - Secret: Your Google API key (from .env file)

3. **Kubeconfig**
   - Kind: Secret file
   - ID: `kubeconfig`
   - File: Upload your kubeconfig file (typically from ~/.kube/config)

## 4. Configure Tools

Go to Manage Jenkins > Tools:

1. **Maven Installation**
   - Name: `Maven`
   - Install automatically: Check
   - Version: Select the latest version

2. **Docker Installation** (if needed)
   - Name: `Docker`
   - Install automatically: Check
   - Version: Select the latest version

## 5. Create Jenkins Pipeline

1. From Jenkins dashboard, click "New Item"
2. Enter a name (e.g., "HealthcareChatbot")
3. Select "Pipeline" and click OK
4. In the configuration:
   - Under "Pipeline", select "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/Aman7532/Healthhh`
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`
5. Click Save

## 6. Environment Requirements

Ensure your Jenkins server has:

1. **Docker**:
   ```bash
   # Check Docker installation
   docker --version
   ```

2. **Python 3**:
   ```bash
   # Check Python installation
   python3 --version
   ```

3. **kubectl**:
   ```bash
   # Check kubectl installation
   kubectl version --client
   ```

4. **Ansible**:
   ```bash
   # Check Ansible installation
   ansible --version
   ```

## 7. Troubleshooting Common Issues

### Missing Google API Key
If you see `ERROR: google-api-key`, you need to add this credential in Jenkins.

### Docker Permission Issues
If Jenkins can't access Docker, run:
```bash
sudo usermod -aG docker jenkins
sudo service jenkins restart
```

### Kubernetes Access Issues
Make sure your kubeconfig file is valid and the cluster is accessible from the Jenkins server.

### Python Environment Issues
If you encounter Python-related errors, ensure Python 3 is installed and accessible to the Jenkins user.

## 8. Running the Pipeline

1. Go to your pipeline in Jenkins
2. Click "Build Now"
3. Monitor the build progress in the "Console Output"

## 9. Verifying Deployment

After successful pipeline execution:

1. Check if the Docker image was pushed:
   ```bash
   docker pull aman7532/healthcare-chatbot:latest
   ```

2. Verify Kubernetes deployment:
   ```bash
   kubectl get pods -n healthcare-chatbot
   ```

3. Access the application at http://localhost:8090 (after port forwarding is set up)

## 10. Next Steps

- Set up automated testing
- Configure notifications (email, Slack)
- Set up monitoring with Prometheus/Grafana
- Implement automated rollback on failure
