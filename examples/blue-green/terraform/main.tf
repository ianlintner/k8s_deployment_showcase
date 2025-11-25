resource "kubernetes_namespace" "blue_green" {
  metadata {
    name = var.namespace
    labels = {
      app      = "blue-green-demo"
      strategy = "blue-green"
    }
  }
}

# Blue Deployment
resource "kubernetes_deployment" "blue" {
  metadata {
    name      = "app-blue"
    namespace = kubernetes_namespace.blue_green.metadata[0].name
    labels = {
      app     = var.app_name
      version = "blue"
    }
  }

  spec {
    replicas = var.blue_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "blue"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "blue"
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
            value = var.blue_version
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
            name = kubernetes_config_map.blue_html.metadata[0].name
          }
        }
      }
    }
  }
}

# Green Deployment
resource "kubernetes_deployment" "green" {
  metadata {
    name      = "app-green"
    namespace = kubernetes_namespace.blue_green.metadata[0].name
    labels = {
      app     = var.app_name
      version = "green"
    }
  }

  spec {
    replicas = var.green_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "green"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "green"
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
            value = var.green_version
          }

          env {
            name  = "APP_COLOR"
            value = "green"
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
            name = kubernetes_config_map.green_html.metadata[0].name
          }
        }
      }
    }
  }
}

# Service - routes to active color
resource "kubernetes_service" "app" {
  metadata {
    name      = "app-service"
    namespace = kubernetes_namespace.blue_green.metadata[0].name
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
      version = var.active_color
    }
  }
}

# Blue ConfigMap
resource "kubernetes_config_map" "blue_html" {
  metadata {
    name      = "app-blue-html"
    namespace = kubernetes_namespace.blue_green.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Blue/Green Demo - Blue</title>
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
              .indicator {
                  width: 100px;
                  height: 100px;
                  border-radius: 50%;
                  background: #0066cc;
                  margin: 20px auto;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  color: white;
                  font-weight: bold;
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Blue/Green Deployment</h1>
              <p class="version">Version: ${var.blue_version}</p>
              <div class="indicator">BLUE</div>
              <p>This is the <strong>Blue</strong> deployment</p>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}

# Green ConfigMap
resource "kubernetes_config_map" "green_html" {
  metadata {
    name      = "app-green-html"
    namespace = kubernetes_namespace.blue_green.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>Blue/Green Demo - Green</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  margin: 0;
                  background: linear-gradient(135deg, #134e5e 0%, #71b280 100%);
              }
              .container {
                  text-align: center;
                  background: white;
                  padding: 40px 60px;
                  border-radius: 16px;
                  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              }
              h1 { color: #134e5e; }
              .version { color: #28a745; font-size: 24px; margin: 20px 0; }
              .indicator {
                  width: 100px;
                  height: 100px;
                  border-radius: 50%;
                  background: #28a745;
                  margin: 20px auto;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  color: white;
                  font-weight: bold;
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Blue/Green Deployment</h1>
              <p class="version">Version: ${var.green_version}</p>
              <div class="indicator">GREEN</div>
              <p>This is the <strong>Green</strong> deployment</p>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}
