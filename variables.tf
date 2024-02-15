resource "random_string" "resource_name" {
  upper   = false
  special = false
  length  = 6
}

variable "project-name" {
  type = string
}

variable "vpc_count" {
  type = number
}

variable "webapp_subnet_cidr_ranges" {
  type = list(string)
}

variable "db_subnet_cidr_ranges" {
  type = list(string)
}

variable "deployment_region" {
  type = string
}

variable "egress_cidr_blocks" {
  type = list(string)
}

variable "default_internet_gateway" {
  type = string
}