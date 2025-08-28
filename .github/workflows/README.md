# CI/CD Workflow for simple-app

This document explains the GitHub Actions workflow used to build, test, and deploy the `simple-app` Flask service.

## Workflow Location
- `.github/workflows/deploy.yaml`

## Workflow Steps
1. **Checkout code**
2. **Run Python tests**
   - Installs dependencies from `app/requirements.txt`
   - Runs tests in `app/test_app.py` using `pytest`
3. **Build and push Docker image**
   - Builds Docker image for the app
   - Pushes to Docker Hub as both `latest` and commit SHA tags
4. **Deploy to Kubernetes via SSH**
   - SSH into the VM
   - Pulls latest code
   - Runs Helm to deploy:
     - To `prod` namespace if branch is `main` or `master`
     - To `qa` namespace for other branches

## Secrets Required
- `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`: Docker Hub credentials
- `VM_HOST`, `VM_USER`, `VM_SSH_KEY`: SSH access to the VM

## How Environment Is Selected
- **main/master branch**: Deploys to `prod` namespace with `values-prod.yaml`
- **Other branches**: Deploys to `qa` namespace with `values-qa.yaml`

## How Image Tagging Works
- Docker images are tagged with both `latest` and the commit SHA
- Helm uses the commit SHA tag for deployments

## How to Run Tests Locally
```bash
pip install -r app/requirements.txt
pytest app/
```

## Troubleshooting
- If deployment fails, check the workflow logs in GitHub Actions
- If image is not found, ensure both tags are pushed to Docker Hub
- If Helm or kubectl are not found on the VM, install them and set up your PATH
