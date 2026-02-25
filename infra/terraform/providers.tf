provider "yandex" {
  token              = var.yc_token
  cloud_id           = var.cloud_id
  folder_id          = var.folder_id
  zone               = var.zone
  storage_access_key = var.storage_access_key
  storage_secret_key = var.storage_secret_key
}
