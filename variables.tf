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

variable "webapp_subnet_cidr_range" {
  type = string
}

variable "db_subnet_cidr_range" {
  type = string
}

variable "deployment_region" {
  type = string
}

variable "egress_cidr_block" {
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

variable "ssh_port" {
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

variable "disk_size" {
  type = number
}

variable "disk_type" {
  type = string
}