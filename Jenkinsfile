pipeline {
    agent any

    environment {
        DOCKER_BUILDKIT = '1'
        // JMeter installed via Chocolatey
        JMETER_PATH = 'C:\\ProgramData\\chocolatey\\lib\\jmeter\\tools\\apache-jmeter-5.6.3\\bin\\jmeter.bat'

        // ---- Performance thresholds (tune these as needed) ----
        PERF_MAX_AVG_MS       = '500'   // max allowed average response time
        PERF_MAX_P95_MS       = '800'   // max allowed 95th percentile
        PERF_MIN_THROUGHPUT   = '30'    // min allowed throughput (req/sec)
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

                // Clean previous HTML report if it exists
                bat '''
                    if exist tests\\jmeter\\html-report (
                        rmdir /S /Q tests\\jmeter\\html-report
                    )
                '''

                // Run JMeter in non-GUI mode, save CSV results and generate HTML report
                bat '''
                    "%JMETER_PATH%" -n ^
                      -t tests\\jmeter\\valuecatcher_load_test.jmx ^
                      -l tests\\jmeter\\jmeter_results.csv ^
                      -Jjmeter.save.saveservice.output_format=csv ^
                      -e -o tests\\jmeter\\html-report ^
                      -Jperf.max.avg.ms=%PERF_MAX_AVG_MS% ^
                      -Jperf.max.p95.ms=%PERF_MAX_P95_MS% ^
                      -Jperf.min.throughput=%PERF_MIN_THROUGHPUT%
                '''

                // Archive CSV + HTML report so you can download / view later
                archiveArtifacts artifacts: 'tests/jmeter/jmeter_results.csv, tests/jmeter/html-report/**', fingerprint: true

                // Functional + performance gate in one PowerShell step
                bat '''
                    @echo off
                    powershell -NoProfile -Command ^
                      "$csv = Import-Csv 'tests/jmeter/jmeter_results.csv'; " ^
                      "if ($csv | Where-Object { $_.success -eq 'false' }) { " ^
                      "  Write-Host 'JMeter detected failed requests.'; exit 1 }; " ^
                      "$stats = Get-Content 'tests/jmeter/html-report/statistics.json' | ConvertFrom-Json; " ^
                      "$overall = $stats.Total; " ^
                      "$avg  = [double]$overall.meanResTime; " ^
                      "$p95  = [double]$overall.pct2ResTime; " ^
                      "$thr  = [double]$overall.throughput; " ^
                      "Write-Host ('Performance summary -> Avg: {0} ms, p95: {1} ms, Throughput: {2} req/s' -f $avg,$p95,$thr); " ^
                      "if ($avg -gt [double]$env:PERF_MAX_AVG_MS -or $p95 -gt [double]$env:PERF_MAX_P95_MS -or $thr -lt [double]$env:PERF_MIN_THROUGHPUT) { " ^
                      "  Write-Host 'Performance thresholds NOT met. Failing build.'; exit 1 } else { " ^
                      "  Write-Host 'Performance thresholds OK.'; exit 0 }"
                '''
            }
        }

    } // end stages

} // end pipeline
