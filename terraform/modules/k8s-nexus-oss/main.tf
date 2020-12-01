# Persistent volume on the EFS with Access Point
# NOTE: this assumes CSI driver for EFS is available on cluster
resource "kubernetes_manifest" "nexus-pv" {
  provider = kubernetes-alpha
  depends_on = [var.nexus-targets]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolume"
    "metadata" = {
      "name" = "persistent-volume-efs-ap"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "capacity" = {
        "storage" = "5Gi"
      }
      "csi" = {
        "driver" = "efs.csi.aws.com"
        "volumeHandle" = "${var.nexus-fs}::${var.nexus-ap}"
      }
      "persistentVolumeReclaimPolicy" = "Retain"
      "storageClassName" = "efs-sc"
      "volumeMode" = "Filesystem"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "nexus-pvc" {
  depends_on = [kubernetes_manifest.nexus-pv]
  metadata {
    name = "nexus-pvc"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    volume_name = "nexus-pv"
  }
}

resource "kubernetes_service" "nexus-oss" {
  metadata {
    name = "nexus-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nexus-oss.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8081
    }
    type = "NodePort"
  }
}

resource "kubernetes_deployment" "nexus-oss" {
  metadata {
    name = "nexus-oss"
    labels = {
      App     = var.application
      Env     = var.environment
      Version = var.ver
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = var.application
      }
    }
    template {
      metadata {
        labels = {
          App = var.application
        }
      }
      spec {
        # Assumes we have a special type of node to run nexus TODO: must be more generic
        node_selector = {
          "Environment" = "nexus"
        }

        volume {
          name = "nexus-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.nexus-pvc.metadata.0.name
          }
        }

        container {
          image = var.nexus-image-tag
          name  = var.application
          env {
            name  = "MAX_HEAP"
            value = "800m"
          }
          env {
            name  = "MIN_HEAP"
            value = "300m"
          }
          env {
            name = "NEXUS_SECURITY_RANDOMPASSWORD"
            value = "false"
          }
          volume_mount {
            name = "nexus-data"
            mount_path = "/nexus-data"
            }
          port {
            container_port = 8081
          }
          resources {
            limits {
              cpu    = "1000m"
              memory = "4G"
            }
            requests {
              cpu    = "500m"
              memory = "2G"
            }
          }
        }
      }
    }
  }
}