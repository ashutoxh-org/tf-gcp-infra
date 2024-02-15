project-name = "csye-6225-development"
vpc_count = 1 # Quota 'NETWORKS' Limit: 5.0 globally
egress_cidr_blocks = ["0.0.0.0/0"]
webapp_subnet_cidr_ranges = ["10.0.1.0/24"]
db_subnet_cidr_ranges = ["10.0.11.0/24"]
deployment_region = "us-east5"
default_internet_gateway = "default-internet-gateway"