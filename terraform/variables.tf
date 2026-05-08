variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Region GCP"
  default     = "europe-central2"
}

variable "zones" {
  type        = list(string)
  description = "3 zones == HA"
  default     = ["europe-central2-b", "europe-central2-c", "europe-central2-a"]
}

variable "subnet_cidr" {
  type        = string
  description = "CIDRs"
  default     = "10.20.0.0/24"
}

variable "cache_machine_type" {
  type        = string
  description = "VM for Redis/Valkey"
  default     = "n2-highmem-4"
}

variable "riot_machine_type" {
  type        = string
  description = "Typ VM dla migratora RIOT"
  default     = "n2-standard-8"
}

variable "cache_disk_gb" {
  type        = number
  description = "Dysk dla Redis/Valkey (AOF + RDB)"
  default     = 100
}

variable "riot_disk_gb" {
  type        = number
  description = "Dysk dla RIOT (logi, stan Spring Batch)"
  default     = 50
}

variable "dns_zone_name" {
  type    = string
  default = "cache-internal"
}

variable "dns_domain" {
  type        = string
  description = "Note the dot at te end"
  default     = "internal.vizard.gcp."
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "valkey_password" {
  type      = string
  sensitive = true
}
