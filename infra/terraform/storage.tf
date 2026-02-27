resource "yandex_storage_bucket" "assets" {
  count  = var.create_assets_bucket ? 1 : 0
  bucket = var.assets_bucket_name

  force_destroy = false

  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  versioning {
    enabled = true
  }
}
