pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub..."
                checkout scm
            }
        }

        stage('Build (MVP)') {
            steps {
                echo "Simulating build step for my-valuecatcher-service..."
                // later: npm install, tests, etc.
            }
        }

        stage('Test (MVP)') {
            steps {
                echo "Simulating tests..."
                // later: add real tests
            }
        }
    }
}
