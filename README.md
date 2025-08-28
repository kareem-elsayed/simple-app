# simple-app

A basic Python Flask web application, containerized with Docker and deployable to Kubernetes using Helm.

## Features
- One endpoint:
  - `/` : Returns a hello message and the environment name
- Configurable environment name via Kubernetes Secret
- Dockerized for easy deployment
- Helm chart for Kubernetes deployment (with prod and QA values)

## Directory Structure
```
app/
  app.py
  requirements.txt
charts/
  simple-app/
    Chart.yaml
    values.yaml
    values-prod.yaml
    values-qa.yaml
    templates/
      deployment.yaml
      service.yaml
      secret.yaml
      ...
Dockerfile
README.md
```

## Local Development
1. Create and activate a Python virtual environment
2. Install dependencies from `requirements.txt`
3. Run the Flask app:
   ```bash
   python app/app.py
   ```

## Docker Usage
1. Build the Docker image:
   ```bash
   docker build -t simple-app .
   ```
2. Run the container:
   ```bash
   docker run -p 5000:5000 simple-app
   ```

## Kubernetes Deployment (with Helm)
1. Install to QA:
   ```bash
   helm install simple-app-qa ./charts/simple-app -f charts/simple-app/values-qa.yaml --namespace qa --create-namespace
   ```
2. Install to Production:
   ```bash
   helm install simple-app-prod ./charts/simple-app -f charts/simple-app/values-prod.yaml --namespace prod --create-namespace
   ```

## Port Forwarding to Access the Service
```bash
kubectl port-forward svc/simple-app-prod 8080:80 -n prod
```
Access the app at [http://localhost:8080](http://localhost:8080)

## Environment Configuration
- The environment name is stored as a Kubernetes Secret and injected as the `ENV_NAME` environment variable.
- Change the value in `values-qa.yaml` or `values-prod.yaml` under `secrets.envName` as needed.

## Endpoints
- `GET /` : Returns hello message and environment name
