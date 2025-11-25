resource "kubernetes_namespace" "shadow" {
  metadata {
    name = var.namespace
    labels = {
      app              = "shadow-demo"
      strategy         = "shadow-mirroring"
      istio-injection  = var.enable_istio_injection ? "enabled" : "disabled"
    }
  }
}

# Production Deployment
resource "kubernetes_deployment" "production" {
  metadata {
    name      = "app-production"
    namespace = kubernetes_namespace.shadow.metadata[0].name
    labels = {
      app     = var.app_name
      version = "production"
    }
  }

  spec {
    replicas = var.production_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "production"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "production"
        }
      }

      spec {
        container {
          name  = "app"
          image = "${var.image_repository}:${var.image_tag}"

          port {
            container_port = 80
          }

          env {
            name  = "APP_VERSION"
            value = var.production_version
          }

          env {
            name  = "APP_COLOR"
            value = "blue"
          }

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "200m"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          volume_mount {
            name       = "html-config"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html-config"
          config_map {
            name = kubernetes_config_map.production_html.metadata[0].name
          }
        }
      }
    }
  }
}

# Shadow Deployment
resource "kubernetes_deployment" "shadow" {
  count = var.shadow_enabled ? 1 : 0

  metadata {
    name      = "app-shadow"
    namespace = kubernetes_namespace.shadow.metadata[0].name
    labels = {
      app     = var.app_name
      version = "shadow"
    }
  }

  spec {
    replicas = var.shadow_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "shadow"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "shadow"
        }
      }

      spec {
        container {
          name  = "app"
          image = "${var.image_repository}:${var.image_tag}"

          port {
            container_port = 80
          }

          env {
            name  = "APP_VERSION"
            value = var.shadow_version
          }

          env {
            name  = "APP_COLOR"
            value = "gray"
          }

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "200m"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          volume_mount {
            name       = "html-config"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html-config"
          config_map {
            name = kubernetes_config_map.shadow_html[0].metadata[0].name
          }
        }
      }
    }
  }
}

# Main Service (points to production)
resource "kubernetes_service" "app" {
  metadata {
    name      = "app-service"
    namespace = kubernetes_namespace.shadow.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      app     = var.app_name
      version = "production"
    }
  }
}

# Production-only Service
resource "kubernetes_service" "production" {
  metadata {
    name      = "app-production-service"
    namespace = kubernetes_namespace.shadow.metadata[0].name
    labels = {
      app     = var.app_name
      version = "production"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      app     = var.app_name
      version = "production"
    }
  }
}

# Shadow-only Service
resource "kubernetes_service" "shadow" {
  count = var.shadow_enabled ? 1 : 0

  metadata {
    name      = "app-shadow-service"
    namespace = kubernetes_namespace.shadow.metadata[0].name
    labels = {
      app     = var.app_name
      version = "shadow"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      app     = var.app_name
      version = "shadow"
    }
  }
}

# Production ConfigMap
resource "kubernetes_config_map" "production_html" {
  metadata {
    name      = "app-production-html"
    namespace = kubernetes_namespace.shadow.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Shadow Demo - Production</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  margin: 0;
                  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
              }
              .container {
                  text-align: center;
                  background: white;
                  padding: 40px 60px;
                  border-radius: 16px;
                  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              }
              h1 { color: #1e3c72; }
              .version { color: #0066cc; font-size: 24px; margin: 20px 0; }
              .status {
                  padding: 10px 20px;
                  background: #0066cc;
                  color: white;
                  border-radius: 20px;
                  display: inline-block;
                  margin: 10px 0;
              }
              .icon { font-size: 48px; margin: 20px 0; }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Shadow/Mirroring Demo</h1>
              <p class="version">Version: ${var.production_version}</p>
              <div class="icon">☀️</div>
              <div class="status">PRODUCTION</div>
              <p>This is the <strong>Production</strong> version</p>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}

# Shadow ConfigMap
resource "kubernetes_config_map" "shadow_html" {
  count = var.shadow_enabled ? 1 : 0

  metadata {
    name      = "app-shadow-html"
    namespace = kubernetes_namespace.shadow.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Shadow Demo - Shadow</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  margin: 0;
                  background: linear-gradient(135deg, #2c3e50 0%, #4a5568 100%);
              }
              .container {
                  text-align: center;
                  background: white;
                  padding: 40px 60px;
                  border-radius: 16px;
                  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              }
              h1 { color: #2c3e50; }
              .version { color: #718096; font-size: 24px; margin: 20px 0; }
              .status {
                  padding: 10px 20px;
                  background: #718096;
                  color: white;
                  border-radius: 20px;
                  display: inline-block;
                  margin: 10px 0;
              }
              .icon { font-size: 48px; margin: 20px 0; }
              .note {
                  background: #f0f0f0;
                  padding: 10px;
                  border-radius: 8px;
                  margin-top: 15px;
                  font-style: italic;
                  color: #666;
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Shadow/Mirroring Demo</h1>
              <p class="version">Version: ${var.shadow_version}</p>
              <div class="icon">🌑</div>
              <div class="status">SHADOW</div>
              <p>This is the <strong>Shadow</strong> version</p>
              <div class="note">
                  Receives mirrored traffic<br>
                  Responses are discarded
              </div>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}
