output "cluster_id" {
  value = yandex_kubernetes_cluster.main.id
}

output "cluster_name" {
  value = yandex_kubernetes_cluster.main.name
}

output "kubeconfig_command" {
  value = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.main.id} --external --force"
}

output "assets_bucket" {
  value = var.assets_bucket_name
}
