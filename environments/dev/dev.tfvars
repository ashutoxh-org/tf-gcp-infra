#Project Level
project_id = "csye-6225-development"
deployment_region = "us-east5"
deployment_zone = "us-east5-a"

#VPC
auto_create_subnetworks = false
routing_mode = "REGIONAL"
delete_default_routes_on_create = true

#SUBNET
webapp_subnet_cidr_range = "10.0.1.0/24"
db_subnet_cidr_range = "10.0.2.0/24"

#Route
internet_access_route = "0.0.0.0/0"
default_internet_gateway = "default-internet-gateway"

#Firewall
protocol = "tcp"
http_port = ["80"]
https_port = ["443"]
app_port = ["8080"]
source_ranges = ["0.0.0.0/0"]
webapp_firewall_http_tag = "webapp-firewall-http"
webapp_firewall_https_tag = "webapp-firewall-https"
webapp_firewall_app_tag = "webapp-firewall-app"
db_firewall_http_tag = "db-firewall-http"
db_firewall_https_tag = "db-firewall-https"

#DB instance
database_tier = "db-custom-1-3840"  # 1 CPu and 3840 MB or 3.84 GB RAM, The total memory must be at least 3840MiB
database_version = "POSTGRES_15"
db_disk_size       = 10
db_disk_type       = "PD_SSD"
availability_type = "REGIONAL"
db_user = "webapp_user"

#Webapp instance
machine_type = "e2-small"
custom_image = "webapp-centos-stream-8-20240319092846"
webapp_disk_size = 20
webapp_disk_type = "pd-balanced"
sa_email = "packer@csye-6225-development.iam.gserviceaccount.com"
sa_scopes = ["https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write"]
