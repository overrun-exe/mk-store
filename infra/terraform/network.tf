resource "yandex_vpc_network" "main" {
  name = "${var.cluster_name}-network"
}

resource "yandex_vpc_subnet" "main" {
  name           = "${var.cluster_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.network_cidr]
}
