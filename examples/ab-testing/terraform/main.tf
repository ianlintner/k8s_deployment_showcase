resource "kubernetes_namespace" "ab_testing" {
  metadata {
    name = var.namespace
    labels = {
      app      = "ab-testing-demo"
      strategy = "ab-testing"
    }
  }
}

# Version A Deployment (Control)
resource "kubernetes_deployment" "version_a" {
  count = var.version_a_enabled ? 1 : 0

  metadata {
    name      = "app-a"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
    labels = {
      app     = var.app_name
      version = "a"
    }
  }

  spec {
    replicas = var.version_a_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "a"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "a"
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
            value = var.version_a_label
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
            name = kubernetes_config_map.version_a_html[0].metadata[0].name
          }
        }
      }
    }
  }
}

# Version B Deployment (Variant)
resource "kubernetes_deployment" "version_b" {
  count = var.version_b_enabled ? 1 : 0

  metadata {
    name      = "app-b"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
    labels = {
      app     = var.app_name
      version = "b"
    }
  }

  spec {
    replicas = var.version_b_replicas

    selector {
      match_labels = {
        app     = var.app_name
        version = "b"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = "b"
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
            value = var.version_b_label
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
            name = kubernetes_config_map.version_b_html[0].metadata[0].name
          }
        }
      }
    }
  }
}

# Combined Service (both versions)
resource "kubernetes_service" "app" {
  metadata {
    name      = "app-service"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
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

# Version A Service
resource "kubernetes_service" "version_a" {
  count = var.version_a_enabled ? 1 : 0

  metadata {
    name      = "app-service-a"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
    labels = {
      app     = var.app_name
      version = "a"
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
      version = "a"
    }
  }
}

# Version B Service
resource "kubernetes_service" "version_b" {
  count = var.version_b_enabled ? 1 : 0

  metadata {
    name      = "app-service-b"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
    labels = {
      app     = var.app_name
      version = "b"
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
      version = "b"
    }
  }
}

# Version A ConfigMap
resource "kubernetes_config_map" "version_a_html" {
  count = var.version_a_enabled ? 1 : 0

  metadata {
    name      = "app-a-html"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>A/B Testing Demo - Version A</title>
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
              .version {
                  font-size: 72px;
                  font-weight: bold;
                  color: #0066cc;
                  margin: 20px 0;
              }
              .label {
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
              <h1>A/B Testing Demo</h1>
              <div class="version">${var.version_a_label}</div>
              <div class="label">CONTROL</div>
              <p>This is Version <strong>A</strong> (Control)</p>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}

# Version B ConfigMap
resource "kubernetes_config_map" "version_b_html" {
  count = var.version_b_enabled ? 1 : 0

  metadata {
    name      = "app-b-html"
    namespace = kubernetes_namespace.ab_testing.metadata[0].name
  }

  data = {
    "index.html" = <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
          <title>A/B Testing Demo - Version B</title>
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
              .version {
                  font-size: 72px;
                  font-weight: bold;
                  color: #28a745;
                  margin: 20px 0;
              }
              .label {
                  padding: 10px 20px;
                  background: #28a745;
                  color: white;
                  border-radius: 20px;
                  display: inline-block;
                  margin: 10px 0;
              }
              .new-feature {
                  background: #e8f5e9;
                  padding: 10px;
                  border-radius: 8px;
                  margin-top: 15px;
                  border: 2px dashed #28a745;
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>A/B Testing Demo</h1>
              <div class="version">${var.version_b_label}</div>
              <div class="label">VARIANT</div>
              <p>This is Version <strong>B</strong> (Variant)</p>
              <div class="new-feature">
                  ✨ New Feature: Enhanced UI ✨
              </div>
              <p><small>Deployed via Terraform</small></p>
          </div>
      </body>
      </html>
    EOF
  }
}
