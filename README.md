
## Project Overview
This project demonstrates a production‑style Blue‑Green Deployment using Docker, Kubernetes, and Minikube.

It includes:
-Zero‑downtime release strategy
-Failure simulation (GREEN intentionally broken)
-Health checks
-Automated validation script
-Rollback mechanism
-Windows‑friendly port‑forward instructions

This project deploys a simple Node.js API using:

Docker for containerization
Kubernetes for orchestration
Blue‑Green deployment for safe releases

Key Features
Zero‑downtime deployments
Traffic switching between BLUE (stable) and GREEN (test)
Crash simulation for GREEN
Health‑based validation
Rollback to stable version
Release dashboard
## Architecture Overview
Kubernetes Service routes traffic between deployments
Blue (v1.1.0) = stable version
Green (v1.1.1-broken) = faulty version
Health checks prevent traffic to unhealthy pods
Rollback switches traffic back to Blue

## Project Structure
portfolio_project/
│
├── app/                       # Blue version
├── app_v1.1.1_broken/         # Green version
│
├── k8s/
│   ├── deployment-blue.yaml
│   ├── deployment-green.yaml
│   ├── service.yaml
│
├── scripts/
│   ├── validate.ps1
│   ├── dashboard.ps1
│
├── Dockerfile
└── README.md


## Deployment Workflow
Build Images
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker build -t tdl-api:v1.1.0 .\app\
docker build -t tdl-api:v1.1.1-broken .\app_v1.1.1_broken\

Deploy to Kubernetes
kubectl apply -f k8s/deployment-blue.yaml
kubectl apply -f k8s/deployment-green.yaml
kubectl apply -f k8s/service.yaml

Verify
kubectl get pods
kubectl get svc

## Versioning Strategy
v1.1.0 → Stable (Blue)
v1.1.1-broken → Faulty (Green)
rollback-v1.1.1 → Rollback state
final-submission → Final version

## Failure State
Green deployment is intentionally broken.

kubectl get pods

Example:

tdl-api-blue    1/1   Running
tdl-api-green   0/1   CrashLoopBackOff

## Rollback Decision Process
Rollback is performed when:
-Pods fail health checks
-CrashLoopBackOff is detected
-Validation script returns exit code 1

Rollback Command
kubectl patch service tdl-api-service -p `
  '{"spec": {"selector": {"version": "blue"}}}'

Verification
kubectl get pods

## Validation Script

Validation Script (Exit Code 0 = Healthy)
Script: scripts/validate.ps1

The script checks:
Pod status
Pod readiness
CrashLoopBackOff
Service routing (BLUE vs GREEN)
/health endpoint
Root endpoint

Returns 0 if BLUE is healthy

Returns 1 if GREEN is active or BLUE is broken
Script: scripts/validate.ps1

## Required Outputs

Successful Deployment
tdl-api-blue    Running

Rolling Update
kubectl rollout status deployment tdl-api-green

Failure State
tdl-api-green   CrashLoopBackOff

Successful Rollback
Service routing switched to BLUE
