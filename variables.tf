resource "random_string" "resource_name" {
  upper   = false
  special = false
  length  = 6
}

variable "project_id" {
  type = string
}

variable "routing_mode" {
  type = string
}

variable "auto_create_subnetworks" {
  type = bool
}

variable "delete_default_routes_on_create" {
  type = bool
}

variable "webapp_subnet_cidr_range" {
  type = string
}

variable "db_subnet_cidr_range" {
  type = string
}

variable "function_to_vpc_connector_subnet_cidr_range" {
  type = string
}

variable "deployment_region" {
  type = string
}

variable "internet_access_route" {
  type = string
}

variable "default_internet_gateway" {
  type = string
}

variable "protocol" {
  type = string
}

variable "http_port" {
  type = list(string)
}

variable "https_port" {
  type = list(string)
}

variable "app_port" {
  type = list(string)
}


variable "source_ranges" {
  type = list(string)
}

variable "sa_scopes" {
  type = list(string)
}

variable "sa_email" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "deployment_zone" {
  type = string
}

variable "custom_image" {
  type = string
}

variable "webapp_disk_size" {
  type = number
}

variable "db_disk_size" {
  type = number
}

variable "webapp_disk_type" {
  type = string
}

variable "db_disk_type" {
  type = string
}

variable "webapp_firewall_http_tag" {
  type = string
}

variable "webapp_firewall_https_tag" {
  type = string
}

variable "webapp_firewall_app_tag" {
  type = string
}

variable "db_firewall_http_tag" {
  type = string
}

variable "db_firewall_https_tag" {
  type = string
}

variable "database_version" {
  type = string
}

variable "database_tier" {
  type = string
}

variable "availability_type" {
  type = string
}

variable "db_user" {
  type = string
}

variable "mailgun_token" {
  type = string
}

variable "expiry_time_in_minutes" {
  type = number
}