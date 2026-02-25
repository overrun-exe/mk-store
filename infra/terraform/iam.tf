resource "yandex_iam_service_account" "k8s_cluster" {
  name        = "${var.cluster_name}-cluster-sa"
  description = "Service account for managed Kubernetes control plane"
}

resource "yandex_iam_service_account" "k8s_nodes" {
  name        = "${var.cluster_name}-nodes-sa"
  description = "Service account for managed Kubernetes worker nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster_vpc_admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nodes_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nodes_logging" {
  folder_id = var.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "nodes_monitoring" {
  folder_id = var.folder_id
  role      = "monitoring.editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}
