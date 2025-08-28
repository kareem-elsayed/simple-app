# simple-app Helm Chart

A Helm chart for deploying the simple-app Flask application to Kubernetes with Traefik ingress and SSL support.

## Description

This chart deploys a simple Flask web application with the following features:
- Configurable replicas and autoscaling
- Environment-specific configuration (QA/Production)
- Traefik ingress with SSL certificates via cert-manager
- Secret management for environment variables
- Resource limits and health checks

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Traefik ingress controller
- cert-manager (for SSL certificates)

## Installing the Chart

### QA Environment
```bash
helm install simple-app-qa ./charts/simple-app \
  -f ./charts/simple-app/values-qa.yaml \
  --namespace qa \
  --create-namespace
```

### Production Environment
```bash
helm install simple-app-prod ./charts/simple-app \
  -f ./charts/simple-app/values-prod.yaml \
  --namespace prod \
  --create-namespace
```

## Upgrading the Chart

### QA Environment
```bash
helm upgrade simple-app-qa ./charts/simple-app \
  -f ./charts/simple-app/values-qa.yaml \
  --namespace qa
```

### Production Environment
```bash
helm upgrade simple-app-prod ./charts/simple-app \
  -f ./charts/simple-app/values-prod.yaml \
  --namespace prod
```

## Uninstalling the Chart

```bash
# QA
helm uninstall simple-app-qa --namespace qa

# Production
helm uninstall simple-app-prod --namespace prod
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `keko00/simple-app` |
| `image.tag` | Container image tag | `latest` |
| `app.port` | Flask application port | `5000` |
| `app.environment` | Flask environment | `development` |
| `secrets.envName` | Environment name stored in secret | `production` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Target port for service | `5000` |
| `ingress.prodHost` | Production hostname | `simple-service-prod.gitlift.com` |
| `ingress.qaHost` | QA hostname | `simple-service-qa.gitlift.com` |
| `resources.limits.cpu` | CPU limit | varies by environment |
| `resources.limits.memory` | Memory limit | varies by environment |
| `autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |

## Environment-Specific Values

### QA Environment (`values-qa.yaml`)
- 2 replicas
- 500m CPU, 512Mi memory limits
- Autoscaling disabled
- Hostname: `simple-service-qa.gitlift.com`

### Production Environment (`values-prod.yaml`)
- 3 replicas
- 1000m CPU, 1Gi memory limits
- Autoscaling enabled (3-10 replicas)
- Hostname: `simple-service-prod.gitlift.com`

## SSL/TLS Configuration

The chart includes automatic SSL certificate generation using cert-manager and Let's Encrypt:

1. **Prerequisites**: Ensure cert-manager is installed and a ClusterIssuer named `letsencrypt-prod` exists
2. **Automatic certificates**: Certificates are automatically requested and renewed
3. **HTTPS access**: Both QA and Production environments support HTTPS

### Setting up cert-manager (if not already installed)

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
EOF
```

## Ingress Configuration

The chart creates environment-specific ingress resources:

- **QA**: Creates ingress only when `ingress.qaHost` is defined
- **Production**: Creates ingress only when `ingress.prodHost` is defined
- **Traefik**: Uses Traefik ingress controller with automatic SSL
- **Conditional deployment**: Only the appropriate ingress is created for each environment

## Health Checks

The application includes:
- **Liveness probe**: Checks if the application is running
- **Readiness probe**: Checks if the application is ready to receive traffic
- **Endpoint**: Both probes check the `/` endpoint

## Security

- **Non-root user**: Containers run as non-root user (UID 1000)
- **Security context**: Privilege escalation disabled
- **Secrets**: Environment variables stored as Kubernetes secrets

## Monitoring and Scaling

### Horizontal Pod Autoscaler (Production only)
- **Enabled**: In production environment
- **Min replicas**: 3
- **Max replicas**: 10
- **Target CPU**: 70%

### Resource Management
- **Requests and limits**: Defined for both CPU and memory
- **Environment-specific**: Different values for QA and Production

## Troubleshooting

### Common Issues

1. **Ingress not accessible**
   - Check if Traefik is running
   - Verify DNS points to your cluster
   - Check ingress status: `kubectl get ingress -A`

2. **SSL certificate issues**
   - Check cert-manager is running: `kubectl get pods -n cert-manager`
   - Check certificate status: `kubectl get certificate -A`
   - Check ClusterIssuer: `kubectl get clusterissuer`

3. **Pod not starting**
   - Check image availability: `kubectl describe pod <pod-name>`
   - Verify resource limits
   - Check secrets are created

### Useful Commands

```bash
# Check pod status
kubectl get pods -n <namespace>

# Check service endpoints
kubectl get endpoints -n <namespace>

# Check ingress status
kubectl get ingress -n <namespace>

# Check certificates
kubectl get certificate -n <namespace>

# View pod logs
kubectl logs -f deployment/simple-app-<env> -n <namespace>
```

## Chart Development

### Testing Changes
```bash
# Dry run
helm install simple-app-test ./charts/simple-app \
  -f ./charts/simple-app/values-qa.yaml \
  --dry-run --debug

# Template rendering
helm template simple-app ./charts/simple-app \
  -f ./charts/simple-app/values-qa.yaml
```

### Linting
```bash
helm lint ./charts/simple-app
```
