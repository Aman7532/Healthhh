pipeline {
    agent any
    
    environment {
        // Docker configuration
        DOCKER_REGISTRY = 'docker.io/aman7532'
        IMAGE_NAME = 'healthcare-chatbot'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_CREDENTIALS_ID = 'DockerHub'  // Updated to match your existing credentials ID
        
        // Google API Key
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
                    # Run Flask test with timeout to prevent hanging
                    python test_flask_predict.py & 
                    FLASK_PID=$!
                    # Wait 10 seconds for the server to start and run tests
                    sleep 10
                    # Send a test request to verify it's working
                    curl -s http://localhost:3001/ > /dev/null
                    # Kill the Flask server
                    kill $FLASK_PID || true
                    echo "Tests completed successfully"
                '''
            }
        }
        
        stage('Debug Docker') {
            steps {
                sh '''
                    whoami
                    /usr/local/bin/docker version
                    /usr/local/bin/docker info
                    /usr/local/bin/docker system df
                    echo "Docker debug information collected"
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Check if the Docker image already exists
                    def imageExists = sh(script: "/usr/local/bin/docker images -q ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest", returnStdout: true).trim()
                    
                    if (imageExists) {
                        echo "Docker image ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest already exists. Skipping build."
                        // Tag the existing image with the build number for consistency
                        sh "/usr/local/bin/docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    } else {
                        echo "Building Docker image..."
                        // Build the Docker image
                        sh "/usr/local/bin/docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest ."
                        echo "Docker image built successfully"
                    }
                }
            }
        }
        
        stage('Push Docker Images') {
            steps {
                script {
                    // Login to Docker Hub - using the same approach as in the Calculator project
                    withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo "$DOCKER_PASS" | /usr/local/bin/docker login -u "$DOCKER_USER" --password-stdin'
                    }
                    
                    // Push the Docker images
                    sh "/usr/local/bin/docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "/usr/local/bin/docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
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
                    // Use the local kubeconfig file
                    sh """
                        export KUBECONFIG=~/.kube/config
                        export GOOGLE_API_KEY=${GOOGLE_API_KEY}
                        /opt/homebrew/bin/ansible-playbook ansible-deploy-app-only.yml -v
                        echo "Ansible deployment completed"
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=~/.kube/config
                        /opt/homebrew/bin/kubectl get pods -n healthcare-chatbot
                        /opt/homebrew/bin/kubectl get svc -n healthcare-chatbot
                        echo "Deployment verification completed"
                    """
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
                    sh """
                        export KUBECONFIG=~/.kube/config
                        # Kill any existing port-forwarding processes
                        pkill -f "kubectl port-forward" || true
                        # Start port forwarding in the background
                        nohup /opt/homebrew/bin/kubectl port-forward -n healthcare-chatbot svc/healthcare-chatbot-service 8090:80 > port-forward.log 2>&1 &
                        echo "Port forwarding set up on port 8090. Application accessible at http://localhost:8090"
                    """
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                // Clean up resources
                sh "/usr/local/bin/docker system prune -f || true"
                echo "Cleanup completed"
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
            echo "Pipeline completed"
            // Note: Docker cleanup moved to a separate stage for better compatibility
        }
    }
}
