📦 ValueCatcher MVP

Minimal Service to Validate DevOps Pipeline Infrastructure

🚀 Purpose of This Application

The ValueCatcher MVP is a very small test application created only to validate and demonstrate a full DevOps CI/CD pipeline, including:

✔ GitHub → Jenkins integration
✔ Automated Docker image build & push to Nexus
✔ Kubernetes (K3s) deployment
✔ Sending deployment status to a simple REST API (this app)
✔ Foundation for future ERP, CMM, monitoring, and rollback integrations

🧪 This is NOT a full production application.
It is a lightweight microservice used to capture and log deployment events from Jenkins during pipeline execution.

🔍 What Does This App Do?

This MVP app exposes just one small API endpoint:

Method	Endpoint	Purpose
POST	/api/ci-events	Receives deployment status from Jenkins and logs it

Example JSON payload sent from Jenkins:

{
  "application": "my-service",
  "version": "23",
  "environment": "dev",
  "status": "SUCCESS",
  "buildNumber": 23,
  "timestamp": "2025-03-10T14:25:00Z"
}


The app simply prints this information in the console as proof that the pipeline automation works correctly.

💡 Why This MVP Exists

This app is used to validate this DevOps Architecture Pipeline ⬇️

[ Developer Commit ]
        │
        ▼
[ GitHub Repository ]
 └─▶ Trigger: Webhook → Jenkins
        │
        ▼
[Jenkins CI/CD Pipeline]
 ├─▶ Trigger: Commit push or PR merge
 ├─▶ Stage 1: Build & Unit Tests (JUnit)
 ├─▶ Stage 2: Code Quality Scan (SonarQube)
 ├─▶ Stage 3: Docker Image Build & Push (Nexus)
 ├─▶ Stage 4: Infrastructure Provisioning (Terraform)
 ├─▶ Stage 5: Deploy Containers to Kubernetes (K3s)
 ├─▶ Stage 6: Integration/UI Tests (Selenium)
 ├─▶ Stage 7: Performance Tests (JMeter)
 ├─▶ Stage 8: Sync Deployment Data → ERP (AVERP)
 ├─▶ Stage 9: Collect Machine Data → CMM Diadem
 ├─▶ Stage 10: Metrics Aggregation (Prometheus)
 └─▶ Stage 11: Visualization & Alerts (Grafana + Mattermost)


🧼 This app only supports Stage 8 (Sync Deployment Data) initially,
but will be later extended to simulate ERP / CMM / Value Tracking signals.

🛠️ Tech Stack
Component	Purpose
Node.js + Express	Lightweight REST API
Docker	Containerization
GitHub	Version control
Jenkins (external)	CI/CD Pipeline
Nexus OSS (external)	Artifact & image registry
K3s Kubernetes (external)	Container runtime
curl / HTTP POST	Pipeline communication
▶️ Run Locally
npm install
npm start


Test it:

curl -X POST http://localhost:3000/api/ci-events \
  -H "Content-Type: application/json" \
  -d '{ "app": "test", "status": "SUCCESS" }'

🐳 Docker Support (Optional)
docker build -t valuecatcher-mvp .
docker run -p 3000:3000 valuecatcher-mvp

🔄 Next Features (Planned)

Store events in JSON file or database (SQLite or MongoDB)

Add GET /logs endpoint to view received CI/CD events

Display events in a simple frontend (HTML dashboard)

Integrate with ERP and CMM simulation data

Show rollout failure/rollback tracking

👨‍💻 Author

lopillo

Would you like me to:
✨ Add a GitHub-friendly badge section (build passing, version, license)?
📘 Add a visual architecture diagram (PNG or Mermaid) to README?
🐳 Create a Docker-compose file to test MVP + Jenkins locally?
🧪 Add a simple frontend to list received deployments?
