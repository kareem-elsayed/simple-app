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

## Testing
Unit tests are written using `pytest` and located in `app/test_app.py`. To run tests locally:

```bash
pip install -r app/requirements.txt
pytest app/
```

## CI/CD Workflow
GitHub Actions is used for automated testing, Docker image building, and deployment:
- On every push or PR, tests are run using pytest.
- If tests pass, a Docker image is built and pushed to Docker Hub with both `latest` and commit SHA tags.
- The app is deployed to a Kubernetes cluster via SSH and Helm:
  - Deploys to `prod` namespace for `main`/`master` branch
  - Deploys to `qa` namespace for other branches
- You can also manually trigger a deployment to `prod` for any branch using the GitHub Actions UI (workflow_dispatch).

See `.github/workflows/deploy.yaml` for details.
