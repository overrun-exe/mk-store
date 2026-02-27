variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "network_cidr" {
  description = "VPC subnet CIDR"
  type        = string
  default     = "10.10.0.0/24"
}

variable "cluster_name" {
  description = "Managed Kubernetes cluster name"
  type        = string
  default     = "mk-store"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_count" {
  description = "K8s node count"
  type        = number
  default     = 2
}

variable "node_cores" {
  description = "CPU cores per node"
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "RAM in GB per node"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Node boot disk size in GB"
  type        = number
  default     = 30
}

variable "node_disk_type" {
  description = "Node boot disk type"
  type        = string
  default     = "network-hdd"
}

variable "node_platform_id" {
  description = "Yandex Compute platform"
  type        = string
  default     = "standard-v3"
}

variable "node_preemptible" {
  description = "Use preemptible nodes for cost optimization"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "Public SSH key for node access"
  type        = string
}

variable "assets_bucket_name" {
  description = "Bucket name for static assets"
  type        = string
}

variable "create_assets_bucket" {
  description = "Create assets bucket via terraform. Keep false if bucket already exists."
  type        = bool
  default     = false
}

variable "storage_access_key" {
  description = "Static access key for Object Storage"
  type        = string
  sensitive   = true
}

variable "storage_secret_key" {
  description = "Static secret key for Object Storage"
  type        = string
  sensitive   = true
}
