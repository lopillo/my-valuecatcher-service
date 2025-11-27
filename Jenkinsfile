pipeline {
    agent any

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
                sh '''
                  npm install
                  npm test
                '''
            }
        }
    }
}
