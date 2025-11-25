# Sample Application

A simple nginx-based web application used to demonstrate Kubernetes deployment strategies.

## Features

- Displays application version and color
- Health and readiness endpoints for Kubernetes probes
- Version API endpoint
- Configurable via environment variables

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_VERSION` | Application version displayed | `1.0.0` |
| `APP_COLOR` | Color indicator for visual differentiation | `blue` |

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Main HTML page |
| `/health` | Health check endpoint |
| `/ready` | Readiness check endpoint |
| `/api/version` | JSON endpoint returning version and color |

## Building the Image

```bash
docker build -t k8s-showcase-app:v1 .
```

## Running Locally

```bash
docker run -p 8080:80 -e APP_VERSION=1.0.0 -e APP_COLOR=blue k8s-showcase-app:v1
```

## Using Pre-built Images

For the examples in this repository, you can use the standard nginx image with custom configurations, or build this image and push it to your registry.

For testing purposes, we recommend using:
- `nginx:1.25-alpine` for production-like scenarios
- `hashicorp/http-echo` for simple echo servers
