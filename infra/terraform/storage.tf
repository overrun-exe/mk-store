resource "yandex_storage_bucket" "tfstate" {
  bucket = var.tfstate_bucket_name
  acl    = "private"

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

resource "yandex_storage_bucket" "assets" {
  bucket = var.assets_bucket_name
  acl    = "private"

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
