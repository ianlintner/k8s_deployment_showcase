# A/B Testing Deployment Strategy

A/B Testing deployment allows you to route traffic to different versions of your application based on specific conditions such as HTTP headers, cookies, or user segments.

## How It Works

1. **Version A**: The control version (baseline)
2. **Version B**: The test version (variant)
3. **Routing**: Traffic is split based on specific rules (headers, cookies, etc.)
4. **Analysis**: Measure metrics to determine which version performs better
5. **Decision**: Roll out the winning version

```
┌─────────────────────────────────────────────────────────────┐
│                        Load Balancer                         │
│                    (Ingress Controller)                      │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │       Traffic Router          │
              │   (Header/Cookie based)       │
              └───────────────┬───────────────┘
              │                               │
    Header: X-Version=A              Header: X-Version=B
    Cookie: ab_test=A                Cookie: ab_test=B
              │                               │
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │  Version A      │             │  Version B      │
    │  (Control)      │             │  (Variant)      │
    │   3 replicas    │             │   3 replicas    │
    └─────────────────┘             └─────────────────┘
```

## Directory Structure

```
ab-testing/
├── manifests/           # Raw Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment-a.yaml
│   ├── deployment-b.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── helm/               # Helm chart
    └── ab-testing/
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- NGINX Ingress Controller (for header/cookie-based routing)
- Helm 3.x (for Helm deployment)

## Routing Methods

### Method 1: Header-Based Routing (NGINX Ingress)

Route traffic based on HTTP headers:
```yaml
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-by-header: "X-Version"
nginx.ingress.kubernetes.io/canary-by-header-value: "B"
```

### Method 2: Cookie-Based Routing

Route traffic based on cookies:
```yaml
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-by-cookie: "ab_test"
```

### Method 3: Service Mesh (Istio/Linkerd)

For production-grade A/B testing, consider using a service mesh.

## Deployment Steps

### Using Raw Manifests

1. **Create namespace and both deployments:**
   ```bash
   kubectl apply -f manifests/namespace.yaml
   kubectl apply -f manifests/deployment-a.yaml
   kubectl apply -f manifests/deployment-b.yaml
   kubectl apply -f manifests/service.yaml
   ```

2. **Apply ingress for routing:**
   ```bash
   kubectl apply -f manifests/ingress.yaml
   ```

3. **Test A/B routing:**
   ```bash
   # Access Version A (default)
   curl http://ab-testing.local/

   # Access Version B (with header)
   curl -H "X-Version: B" http://ab-testing.local/

   # Access Version B (with cookie)
   curl -b "ab_test=version-b" http://ab-testing.local/
   ```

4. **Roll out winning version:**
   ```bash
   # If Version B wins, scale down A and scale up B
   kubectl scale deployment app-a -n ab-testing-demo --replicas=0
   kubectl scale deployment app-b -n ab-testing-demo --replicas=6
   ```

### Using Helm

1. **Install both versions:**
   ```bash
   helm install ab-testing ./helm/ab-testing -n ab-testing-demo --create-namespace
   ```

2. **Configure routing:**
   ```bash
   helm upgrade ab-testing ./helm/ab-testing -n ab-testing-demo \
     --set ingress.enabled=true \
     --set versionB.routing.header="X-Version" \
     --set versionB.routing.headerValue="B"
   ```

3. **Roll out winner:**
   ```bash
   # If Version B wins
   helm upgrade ab-testing ./helm/ab-testing -n ab-testing-demo \
     --set versionA.enabled=false \
     --set versionB.replicaCount=6
   ```

## Testing

```bash
# Port-forward to service
kubectl port-forward svc/app-service -n ab-testing-demo 8080:80

# Test Version A (default)
curl localhost:8080

# Test Version B (with header)
curl -H "X-Version: B" localhost:8080
```

## Metrics to Track

- Conversion rates
- Page load times
- Error rates
- User engagement metrics
- Business KPIs

## Cleanup

```bash
# Using manifests
kubectl delete namespace ab-testing-demo

# Using Helm
helm uninstall ab-testing -n ab-testing-demo
kubectl delete namespace ab-testing-demo
```

## Advantages

- Data-driven decision making
- Test specific features with specific users
- Reduce risk of deploying changes
- Can run multiple experiments simultaneously

## Disadvantages

- Requires proper metrics infrastructure
- More complex routing configuration
- Need enough traffic for statistical significance
- Version management can be complex
