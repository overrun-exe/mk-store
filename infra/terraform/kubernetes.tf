resource "yandex_kubernetes_cluster" "main" {
  name                    = var.cluster_name
  network_id              = yandex_vpc_network.main.id
  service_account_id      = yandex_iam_service_account.k8s_cluster.id
  node_service_account_id = yandex_iam_service_account.k8s_nodes.id
  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

  master {
    version   = var.kubernetes_version
    public_ip = true

    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.main.id
    }

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.cluster_agent,
    yandex_resourcemanager_folder_iam_member.cluster_vpc_admin,
    yandex_resourcemanager_folder_iam_member.nodes_puller,
    yandex_resourcemanager_folder_iam_member.nodes_logging,
    yandex_resourcemanager_folder_iam_member.nodes_monitoring
  ]
}

resource "yandex_kubernetes_node_group" "main" {
  cluster_id = yandex_kubernetes_cluster.main.id
  name       = "${var.cluster_name}-node-group"
  version    = var.kubernetes_version

  instance_template {
    platform_id = var.node_platform_id

    metadata = {
      ssh-keys = "ubuntu:${var.ssh_public_key}"
    }

    resources {
      cores  = var.node_cores
      memory = var.node_memory
    }

    boot_disk {
      type = var.node_disk_type
      size = var.node_disk_size
    }

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.main.id]
    }

    scheduling_policy {
      preemptible = var.node_preemptible
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
}
