resource "random_string" "resource_name" {
  upper   = false
  special = false
  length  = 6
}

variable "project-name" {
  type = string
}

variable "webapp-subnet-cidr-range" {
  type = string
}

variable "db-subnet-cidr-range" {
  type = string
}

variable "region" {
  type = string
}

variable "webapp-egress" {
  type = string
}

variable "internet-gateway" {
  type = string
}