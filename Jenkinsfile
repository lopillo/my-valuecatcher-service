pipeline {
    agent any

    environment {
        APP_NAME = 'my-valuecatcher-service'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out code..."
                checkout scm
            }
        }

        stage('Build & Unit Tests') {
            steps {
                echo "Installing dependencies and running tests..."
                bat """
                  npm install
                  npm test
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                bat """
                  docker build -t %APP_NAME%:%BUILD_NUMBER% .
                """
            }
        }
    }
}
