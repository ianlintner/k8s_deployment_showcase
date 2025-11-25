resource "kubernetes_namespace" "canary" {
  metadata {
    name = var.namespace
    labels = {
      app      = "canary-demo"
      strategy = "canary"
    }
  }
}

# Stable Deployment
resource "kubernetes_deployment" "stable" {
  metadata {
    name      = "app-stable"
    namespace = kubernetes_namespace.canary.metadata[0].name
    labels = {
      app     = var.app_name
      version = "stable"
    }
  }

  spec {
    replicas = var.stable_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "stable"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "stable"
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
            value = var.stable_version
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
            name = kubernetes_config_map.stable_html.metadata[0].name
          }
        }
      }
    }
  }
}

# Canary Deployment
resource "kubernetes_deployment" "canary" {
  count = var.canary_enabled ? 1 : 0

  metadata {
    name      = "app-canary"
    namespace = kubernetes_namespace.canary.metadata[0].name
    labels = {
      app     = var.app_name
      version = "canary"
    }
  }

  spec {
    replicas = var.canary_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "canary"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "canary"
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
            value = var.canary_version
          }

          env {
            name  = "APP_COLOR"
            value = "orange"
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
            name = kubernetes_config_map.canary_html[0].metadata[0].name
          }
        }
      }
    }
  }
}

# Combined Service - routes to both stable and canary based on replica ratio
resource "kubernetes_service" "app" {
  metadata {
    name      = "app-service"
    namespace = kubernetes_namespace.canary.metadata[0].name
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
      app = var.app_name
    }
  }
}

# Stable-only Service
resource "kubernetes_service" "stable" {
  metadata {
    name      = "app-stable-service"
    namespace = kubernetes_namespace.canary.metadata[0].name
    labels = {
      app     = var.app_name
      version = "stable"
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
      version = "stable"
    }
  }
}

# Canary-only Service
resource "kubernetes_service" "canary" {
  count = var.canary_enabled ? 1 : 0

  metadata {
    name      = "app-canary-service"
    namespace = kubernetes_namespace.canary.metadata[0].name
    labels = {
      app     = var.app_name
      version = "canary"
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
      version = "canary"
    }
  }
}

# Stable ConfigMap
resource "kubernetes_config_map" "stable_html" {
  metadata {
    name      = "app-stable-html"
    namespace = kubernetes_namespace.canary.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Canary Demo - Stable</title>
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
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Canary Deployment Demo</h1>
              <p class="version">Version: ${var.stable_version}</p>
              <div class="status">STABLE</div>
              <p>This is the <strong>Stable</strong> version</p>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}

# Canary ConfigMap
resource "kubernetes_config_map" "canary_html" {
  count = var.canary_enabled ? 1 : 0

  metadata {
    name      = "app-canary-html"
    namespace = kubernetes_namespace.canary.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Canary Demo - Canary</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  margin: 0;
                  background: linear-gradient(135deg, #f46b45 0%, #eea849 100%);
              }
              .container {
                  text-align: center;
                  background: white;
                  padding: 40px 60px;
                  border-radius: 16px;
                  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              }
              h1 { color: #f46b45; }
              .version { color: #ff8c00; font-size: 24px; margin: 20px 0; }
              .status {
                  padding: 10px 20px;
                  background: #ff8c00;
                  color: white;
                  border-radius: 20px;
                  display: inline-block;
                  margin: 10px 0;
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Canary Deployment Demo</h1>
              <p class="version">Version: ${var.canary_version}</p>
              <div class="status">CANARY 🐤</div>
              <p>This is the <strong>Canary</strong> version</p>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}
