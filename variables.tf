# Variables
variable "aws_region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

variable "customer_vpc_cidr" {
  description = "The CIDR block for the Customer VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "scrubbing_vpc_cidr" {
  description = "The CIDR block for the Scrubbing VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "application_subnet_cidr" {
  description = "The CIDR block for the Application Subnet in Customer VPC"
  type        = string
  default     = "10.1.2.0/24"
}

variable "glb_endpoint_subnet_cidr" {
  description = "The CIDR block for the GLB Endpoint Subnet in Customer VPC"
  type        = string
  default     = "10.1.111.0/24"
}

variable "scrubbing_mgmt_subnet_cidr_1" {
  description = "The CIDR block for the Management Subnet 1 in Scrubbing VPC"
  type        = string
  default     = "10.10.1.0/24"
}

variable "scrubbing_mgmt_subnet_cidr_2" {
  description = "The CIDR block for the Management Subnet 2 in Scrubbing VPC"
  type        = string
  default     = "10.10.4.0/24"
}

variable "defensepro_data_subnet_cidr_1" {
  description = "The CIDR block for the Data Subnet 1 in Scrubbing VPC"
  type        = string
  default     = "10.10.2.0/24"
}

variable "defensepro_data_subnet_cidr_2" {
  description = "The CIDR block for the Data Subnet 2 in Scrubbing VPC"
  type        = string
  default     = "10.10.3.0/24"
}

variable "availability_zone_suffix_1" {
  description = "The first availability zone suffix to use (e.g., 'a')"
  type        = string
  default     = "a"
}

variable "availability_zone_suffix_2" {
  description = "The second availability zone suffix to use (e.g., 'b')"
  type        = string
  default     = "b"
}

variable "defensepro_ami_id" {
  description = "The AMI ID for DefensePro"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for DefensePro"
  type        = string
  default     = "r5dn.large"
}

variable "admin_computer_network_for_ssh" {
  description = "Your IP address for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "deployment_index" {
  description = "A number to include in resource names"
  type        = string
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "MyProject"
}