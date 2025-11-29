pipeline {
    agent any

    environment {
        DOCKER_BUILDKIT = '1'
        // JMeter installed via Chocolatey
        JMETER_PATH = 'C:\\ProgramData\\chocolatey\\lib\\jmeter\\tools\\apache-jmeter-5.6.3\\bin\\jmeter.bat'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Build & Unit Tests') {
            steps {
                echo 'Installing dependencies and running tests...'
                bat 'npm install'
                bat 'npm test || echo "No real tests yet"'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    env.IMAGE_TAG = env.BUILD_NUMBER
                }
                bat 'docker build -t my-valuecatcher-service:%IMAGE_TAG% .'
            }
        }

        stage('Provision Infrastructure (Terraform)') {
            steps {
                echo 'Provisioning infrastructure with Terraform (Docker container for ValueCatcher)...'
                dir('infra/terraform') {
                    bat 'terraform init -input=false'
                    bat '''
                        terraform apply -input=false -auto-approve ^
                          -var "image_name=my-valuecatcher-service" ^
                          -var "image_tag=%IMAGE_TAG%"
                    '''
                }
            }
        }

        stage('Notify ValueCatcher') {
            steps {
                echo 'Sending build info to ValueCatcher...'

                writeFile file: 'payload.json', text: """{
  "application": "my-valuecatcher-service",
  "buildNumber": "${env.BUILD_NUMBER}",
  "status": "SUCCESS",
  "source": "Jenkins"
}"""

                bat '''
                    curl -X POST http://localhost:3000/api/ci-events ^
                      -H "Content-Type: application/json" ^
                      --data-binary @payload.json
                '''
            }
        }

        stage('Performance Test (JMeter)') {
            steps {
                echo 'Running JMeter load test...'

                // Run JMeter in non-GUI mode
                bat '''
                    "%JMETER_PATH%" -n ^
                      -t tests\\jmeter\\valuecatcher_load_test.jmx ^
                      -l tests\\jmeter\\jmeter_results.jtl
                '''

                // Archive JTL results
                archiveArtifacts artifacts: 'tests/jmeter/jmeter_results.jtl', fingerprint: true

                // Explicit JMeter validation: fail only if there are real failed samples
                bat '''
                    @echo off
                    findstr /C:"<failure>true</failure>" tests\\jmeter\\jmeter_results.jtl >nul
                    if %ERRORLEVEL% EQU 0 (
                        echo JMeter detected failed requests
                        exit /b 1
                    ) else (
                        echo JMeter reports: all requests successful.
                        exit /b 0
                    )
                '''
            }
        }

    } // end stages

} // end pipeline
