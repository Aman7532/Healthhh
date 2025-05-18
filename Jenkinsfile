pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io/aman7532'
        IMAGE_NAME = 'healthcare-chatbot'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        KUBECONFIG_ID = 'kubeconfig'
        GOOGLE_API_KEY = credentials('google-api-key')
    }
    
    // Use tools that are configured in your Jenkins instance
    // If you don't have these tools configured, you can remove or modify this section
    tools {
        maven 'Maven'
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
                echo "Checked out the code from SCM"
            }
        }
        
        stage('Setup Python Environment') {
            steps {
                sh '''
                    # Use system Python or specify the full path if needed
                    /usr/bin/python3 -m venv venv || true
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirement.txt
                    echo "Python environment setup complete"
                '''
            }
        }
        
        stage('Download NLTK Data') {
            steps {
                sh '''
                    . venv/bin/activate
                    python -c "import nltk; nltk.download('punkt'); nltk.download('averaged_perceptron_tagger')"
                    echo "NLTK data downloaded successfully"
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    python test_model.py
                    python test_flask_predict.py
                    echo "Tests completed successfully"
                '''
            }
        }
        
        stage('Debug Docker') {
            steps {
                sh '''
                    docker info
                    docker system df
                    echo "Docker debug information collected"
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
                    echo "Docker image built successfully"
                }
            }
        }
        
        stage('Push Docker Images') {
            steps {
                script {
                    // Login to Docker Hub
                    withCredentials([string(credentialsId: DOCKER_CREDENTIALS_ID, variable: 'DOCKER_PASSWORD')]) {
                        sh "echo ${DOCKER_PASSWORD} | docker login ${DOCKER_REGISTRY} -u aman7532 --password-stdin"
                    }
                    
                    // Push the Docker images
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    echo "Docker images pushed successfully"
                }
            }
        }
        
        stage('Prepare Ansible Environment') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install ansible kubernetes openshift
                    echo "Ansible environment prepared"
                '''
            }
        }
        
        stage('Run Ansible Playbook') {
            steps {
                script {
                    // Set up the Kubernetes config for Ansible
                    withCredentials([file(credentialsId: KUBECONFIG_ID, variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG_FILE}
                            export GOOGLE_API_KEY=${GOOGLE_API_KEY}
                            ansible-playbook ansible-deploy-app-only.yml -v
                            echo "Ansible deployment completed"
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    withCredentials([file(credentialsId: KUBECONFIG_ID, variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG_FILE}
                            kubectl get pods -n healthcare-chatbot
                            kubectl get svc -n healthcare-chatbot
                            echo "Deployment verification completed"
                        """
                    }
                }
            }
        }
        
        stage('Setup Monitoring') {
            steps {
                script {
                    withCredentials([file(credentialsId: KUBECONFIG_ID, variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG_FILE}
                            echo "Setting up basic monitoring for the application"
                            # This is where you would deploy Prometheus/Grafana or other monitoring tools
                            # For now, we'll just create a simple ConfigMap for demonstration
                            kubectl create configmap -n healthcare-chatbot monitoring-config --from-literal=monitoring=enabled || true
                        """
                    }
                }
            }
        }
        
        stage('Setup Port Forwarding') {
            steps {
                script {
                    withCredentials([file(credentialsId: KUBECONFIG_ID, variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            export KUBECONFIG=\${KUBECONFIG_FILE}
                            # Kill any existing port-forwarding processes
                            pkill -f "kubectl port-forward" || true
                            # Start port forwarding in the background
                            nohup kubectl port-forward -n healthcare-chatbot svc/healthcare-chatbot-service 8090:80 > port-forward.log 2>&1 &
                            echo "Port forwarding set up on port 8090. Application accessible at http://localhost:8090"
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo "Pipeline executed successfully!"
            // You could add notifications here (email, Slack, etc.)
        }
        failure {
            echo "Pipeline execution failed!"
            // You could add notifications here (email, Slack, etc.)
        }
        always {
            // Clean up resources
            sh "docker system prune -f || true"
            echo "Cleanup completed"
        }
    }
}
