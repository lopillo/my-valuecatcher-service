pipeline {
    agent any

    environment {
        APP_NAME         = 'my-valuecatcher-service'
        VALUECATCHER_URL = 'http://localhost:3000/api/ci-events'
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

        stage('Notify ValueCatcher') {
            steps {
                echo "Sending build info to ValueCatcher..."

                // 1) Create JSON payload file with build info
                writeFile file: 'payload.json', text: """{
  "application": "${env.APP_NAME}",
  "buildNumber": "${env.BUILD_NUMBER}",
  "branch": "${env.BRANCH_NAME}",
  "status": "SUCCESS"
}"""

                // 2) Use curl (Windows) to POST it to ValueCatcher
                bat """
                  curl -X POST %VALUECATCHER_URL% ^
                    -H "Content-Type: application/json" ^
                    --data-binary @payload.json
                """
            }
        }
    }
}
