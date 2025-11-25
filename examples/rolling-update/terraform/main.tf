resource "kubernetes_namespace" "rolling_update" {
  metadata {
    name = var.namespace
    labels = {
      app      = "rolling-update-demo"
      strategy = "rolling-update"
    }
  }
}

# Rolling Update Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.rolling_update.metadata[0].name
    labels = {
      app = var.app_name
    }
    annotations = {
      "kubernetes.io/change-cause" = "Deployed version ${var.app_version}"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = var.max_surge
        max_unavailable = var.max_unavailable
      }
    }

    min_ready_seconds = var.min_ready_seconds

    template {
      metadata {
        labels = {
          app = var.app_name
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
            value = var.app_version
          }

          env {
            name  = "APP_COLOR"
            value = "purple"
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
            name = kubernetes_config_map.app_html.metadata[0].name
          }
        }
      }
    }
  }
}

# Service
resource "kubernetes_service" "app" {
  metadata {
    name      = "app-service"
    namespace = kubernetes_namespace.rolling_update.metadata[0].name
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

# ConfigMap
resource "kubernetes_config_map" "app_html" {
  metadata {
    name      = "app-html"
    namespace = kubernetes_namespace.rolling_update.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Rolling Update Demo</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  margin: 0;
                  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              }
              .container {
                  text-align: center;
                  background: white;
                  padding: 40px 60px;
                  border-radius: 16px;
                  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              }
              h1 { color: #667eea; }
              .version { color: #764ba2; font-size: 24px; margin: 20px 0; }
              .strategy {
                  padding: 10px 20px;
                  background: #667eea;
                  color: white;
                  border-radius: 20px;
                  display: inline-block;
                  margin: 10px 0;
              }
              .info {
                  background: #f8f9fa;
                  padding: 15px;
                  border-radius: 8px;
                  margin-top: 20px;
                  text-align: left;
              }
              .info p { margin: 5px 0; color: #555; }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Rolling Update Demo</h1>
              <p class="version">Version: ${var.app_version}</p>
              <div class="strategy">ROLLING UPDATE</div>
              <p>Gradual replacement of pods</p>
              <div class="info">
                  <p><strong>maxSurge:</strong> ${var.max_surge}</p>
                  <p><strong>maxUnavailable:</strong> ${var.max_unavailable}</p>
                  <p><strong>minReadySeconds:</strong> ${var.min_ready_seconds}</p>
              </div>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}
