# Output Variables
output "customer_vpc_id" {
  description = "The ID of the Customer VPC"
  value       = aws_vpc.customer_vpc.id
}

output "scrubbing_vpc_id" {
  description = "The ID of the Scrubbing VPC"
  value       = aws_vpc.scrubbing_vpc.id
}

output "application_subnet_id" {
  description = "The ID of the Application Subnet"
  value       = aws_subnet.application_subnet.id
}

output "glb_endpoint_subnet_id" {
  description = "The ID of the GLB Endpoint Subnet"
  value       = aws_subnet.glb_endpoint_subnet.id
}

output "elastic_ip_dp_1" {
  description = "The Elastic IP for DefensePro 1"
  value       = aws_eip.defensepro_eip_1.public_ip
}

output "elastic_ip_dp_2" {
  description = "The Elastic IP for DefensePro 2"
  value       = aws_eip.defensepro_eip_2.public_ip
}

output "deployment_message" {
  description = "Deployment message for the DefensePro instances"
  value = format("DefensePro instances have been deployed to EC2 AWS in region %s. Instance 1 ID: %s, Instance 2 ID: %s. You can access the instances at the following IPs: Instance 1 - %s, Instance 2 - %s. SSH into the instances using port 22 with the default user credentials radware/radware123. It may take 10-15 minutes for the DefensePro instances to fully initialize.", var.aws_region, aws_instance.defensepro_1.id, aws_instance.defensepro_2.id, aws_eip.defensepro_eip_1.public_ip, aws_eip.defensepro_eip_2.public_ip)
}

