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

        stage('Provision Infrastructure (Terraform)') {
            steps {
                echo "Provisioning infrastructure with Terraform (Docker container for ValueCatcher)..."
                dir('infra/terraform') {
                    bat """
                      terraform init -input=false
                      terraform apply -input=false -auto-approve -var "image_name=%APP_NAME%" -var "image_tag=%BUILD_NUMBER%"
                    """
                }
            }
        }

        stage('Notify ValueCatcher') {
            steps {
                echo "Sending build info to ValueCatcher..."

                writeFile file: 'payload.json', text: """{
  "application": "${env.APP_NAME}",
  "buildNumber": "${env.BUILD_NUMBER}",
  "branch": "${env.BRANCH_NAME}",
  "status": "SUCCESS"
}"""

                bat """
                  curl -X POST %VALUECATCHER_URL% ^
                    -H "Content-Type: application/json" ^
                    --data-binary @payload.json
                """
            }
        }

                stage('Performance Test (ValueCatcher))') {
            steps {
                echo "Running performance test against ValueCatcher (autocannon)..."

                // Use the local project binary: node_modules\.bin\autocannon
                bat """
                  node_modules\\.bin\\autocannon -d 10 -c 10 http://localhost:3000/api/ci-events > perf-results.txt
                """

                // Show results inside Jenkins log
                bat "type perf-results.txt"

                // Archive results so you can download them from Jenkins
                archiveArtifacts artifacts: 'perf-results.txt', fingerprint: true
            }
        }

        }
    }
}
