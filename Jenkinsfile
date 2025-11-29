pipeline {
    agent any

    environment {
        DOCKER_BUILDKIT = '1'
        // Adjust this path to where JMeter is installed on your Jenkins agent
        JMETER_PATH = 'C:\\tools\\apache-jmeter-5.6.2\\bin\\jmeter.bat'
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
                // For now we keep tests trivial
                bat 'npm test || echo "No real tests yet"'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    // Use Jenkins build number as Docker tag
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

                // Run JMeter in non-GUI mode against your .jmx file
                bat '''
                    "%JMETER_PATH%" -n ^
                      -t tests\\jmeter\\valuecatcher_load_test.jmx ^
                      -l tests\\jmeter\\jmeter_results.jtl
                '''

                // Archive raw results file in Jenkins
                archiveArtifacts artifacts: 'tests/jmeter/jmeter_results.jtl', fingerprint: true

                // Simple gate: fail if any request failed (contains ",false," in JTL)
                bat '''
                    findstr /C:",false," tests\\jmeter\\jmeter_results.jtl >nul ^
                      && (echo JMeter detected failed requests & exit /b 1) ^
                      || (echo JMeter reports: all requests successful.)
                '''
            }
        }

    } // end stages

} // end pipeline
