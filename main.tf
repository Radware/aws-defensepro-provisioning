provider "aws" {
  region = var.aws_region
}

locals {
  resource_suffix = "AMS_${var.deployment_index}"
  availability_zone_1 = "${var.aws_region}${var.availability_zone_suffix_1}"
  availability_zone_2 = "${var.aws_region}${var.availability_zone_suffix_2}"

  defensepro_data_ip_1 = cidrhost(var.defensepro_data_subnet_cidr_1, 10)
  defensepro_data_ip_2 = cidrhost(var.defensepro_data_subnet_cidr_2, 10)
  scrubbing_mgmt_ip_1 = cidrhost(var.scrubbing_mgmt_subnet_cidr_1, 10)
  scrubbing_mgmt_ip_2 = cidrhost(var.scrubbing_mgmt_subnet_cidr_2, 10)
}

# Common tags
locals {
  common_tags = {
    Project =  var.project_name
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Create the Customer VPC
resource "aws_vpc" "customer_vpc" {
  cidr_block = var.customer_vpc_cidr

  tags = merge(local.common_tags, {
    Name = "Customer-VPC-${local.resource_suffix}"
  })
}

# Create the Scrubbing VPC
resource "aws_vpc" "scrubbing_vpc" {
  cidr_block = var.scrubbing_vpc_cidr

  tags = merge(local.common_tags, {
    Name = "Scrubbing-VPC-${local.resource_suffix}"
  })
}

# Create subnets in the Customer VPC
resource "aws_subnet" "application_subnet" {
  vpc_id            = aws_vpc.customer_vpc.id
  cidr_block        = var.application_subnet_cidr
  availability_zone = local.availability_zone_1

  tags = merge(local.common_tags, {
    Name = "Application-Sub-${local.resource_suffix}"
  })
}

resource "aws_subnet" "glb_endpoint_subnet" {
  vpc_id            = aws_vpc.customer_vpc.id
  cidr_block        = var.glb_endpoint_subnet_cidr
  availability_zone = local.availability_zone_1

  tags = merge(local.common_tags, {
    Name = "GLB-Endpoint-Sub-${local.resource_suffix}"
  })
}

# Create subnets in the Scrubbing VPC
resource "aws_subnet" "scrubbing_mgmt_subnet_1" {
  vpc_id            = aws_vpc.scrubbing_vpc.id
  cidr_block        = var.scrubbing_mgmt_subnet_cidr_1
  availability_zone = local.availability_zone_1

  tags = merge(local.common_tags, {
    Name = "Scrubbing-VPC-MGMT-Sub-1-${local.resource_suffix}"
  })
}

resource "aws_subnet" "scrubbing_mgmt_subnet_2" {
  vpc_id            = aws_vpc.scrubbing_vpc.id
  cidr_block        = var.scrubbing_mgmt_subnet_cidr_2
  availability_zone = local.availability_zone_2

  tags = merge(local.common_tags, {
    Name = "Scrubbing-VPC-MGMT-Sub-2-${local.resource_suffix}"
  })
}

resource "aws_subnet" "defensepro_data_subnet_1" {
  vpc_id            = aws_vpc.scrubbing_vpc.id
  cidr_block        = var.defensepro_data_subnet_cidr_1
  availability_zone = local.availability_zone_1

  tags = merge(local.common_tags, {
    Name = "DefensePro-DATA-Sub-1-${local.resource_suffix}"
  })
}

resource "aws_subnet" "defensepro_data_subnet_2" {
  vpc_id            = aws_vpc.scrubbing_vpc.id
  cidr_block        = var.defensepro_data_subnet_cidr_2
  availability_zone = local.availability_zone_2

  tags = merge(local.common_tags, {
    Name = "DefensePro-DATA-Sub-2-${local.resource_suffix}"
  })
}

# Create security groups
resource "aws_security_group" "sg_customer_vpc" {
  name        = "SG-Customer-VPC-${local.resource_suffix}"
  description = "Security Group for Customer VPC"
  vpc_id      = aws_vpc.customer_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.admin_computer_network_for_ssh]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "sg_data_scrubbing_vpc" {
  name        = "SG-DATA-Scrubbing-VPC-${local.resource_suffix}"
  description = "Security Group for DATA in Scrubbing VPC"
  vpc_id      = aws_vpc.scrubbing_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.glb_endpoint_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "sg_mgmt_scrubbing_vpc" {
  name        = "SG-MGMT-Scrubbing-VPC-${local.resource_suffix}"
  description = "Security Group for MGMT in Scrubbing VPC"
  vpc_id      = aws_vpc.scrubbing_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.admin_computer_network_for_ssh, var.scrubbing_mgmt_subnet_cidr_1, var.scrubbing_mgmt_subnet_cidr_2]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Create network interfaces for DefensePro instances
resource "aws_network_interface" "eth0_1" {
  subnet_id         = aws_subnet.defensepro_data_subnet_1.id
  security_groups   = [aws_security_group.sg_data_scrubbing_vpc.id]
  private_ips       = [local.defensepro_data_ip_1]

  tags = local.common_tags
}

resource "aws_network_interface" "eth0_2" {
  subnet_id         = aws_subnet.defensepro_data_subnet_2.id
  security_groups   = [aws_security_group.sg_data_scrubbing_vpc.id]
  private_ips       = [local.defensepro_data_ip_2]

  tags = local.common_tags
}

resource "aws_network_interface" "eth1_1" {
  subnet_id         = aws_subnet.scrubbing_mgmt_subnet_1.id
  security_groups   = [aws_security_group.sg_mgmt_scrubbing_vpc.id]
  private_ips       = [local.scrubbing_mgmt_ip_1]

  tags = local.common_tags
}

resource "aws_network_interface" "eth1_2" {
  subnet_id         = aws_subnet.scrubbing_mgmt_subnet_2.id
  security_groups   = [aws_security_group.sg_mgmt_scrubbing_vpc.id]
  private_ips       = [local.scrubbing_mgmt_ip_2]

  tags = local.common_tags
}

/*
resource "local_file" "user_data_script" {
  content  = <<-EOT
              #!/bin/bash
              FILE="/mnt/disk/InitialConfig"
              /bin/cat <<EOF > $FILE
              net traffic-encapsulation status set 1
              net traffic-encapsulation protocol set Geneve
              net traffic-encapsulation port set 6081
              net health-check interface set mgmt
              net health-check port set 18000
              net health-check interface set 1
              EOF
  EOT
  filename = "${path.module}/defensepro-setup.sh"
}

resource "aws_s3_bucket" "user_data_bucket" {
  bucket = "radware-dp-user-data-${random_id.bucket_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name = "User-Data-Bucket-${random_id.bucket_suffix.hex}"
  })

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_object" "user_data_script" {
  bucket = aws_s3_bucket.user_data_bucket.bucket
  key    = "init_conf"
  source = local_file.user_data_script.filename
  acl    = "private"
  
  tags = merge(local.common_tags, {
    Name = "User-Data-Script-${random_id.bucket_suffix.hex}"
  })
}

resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "ec2_s3_access_policy"
  description = "Policy to allow EC2 instances to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.user_data_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.user_data_bucket.bucket}/*"
        ],
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_attachment" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_s3_access_profile" {
  name = "ec2_s3_access_profile"
  role = aws_iam_role.ec2_s3_access.name
}

*/

resource "aws_instance" "defensepro_1" {
  ami           = var.defensepro_ami_id
  #iam_instance_profile = aws_iam_instance_profile.ec2_s3_access_profile.name
  instance_type = var.instance_type
  user_data = <<-EOT
              #!/bin/bash
              FILE="/mnt/disk/InitialConfig"
              /bin/cat <<EOF > $FILE
              net traffic-encapsulation status set 1
              net traffic-encapsulation protocol set Geneve
              net traffic-encapsulation port set 6081
              net health-check interface set mgmt
              net health-check port set 18000
              net health-check interface set 1
              EOF
  EOT

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eth0_1.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.eth1_1.id
  }

  availability_zone = local.availability_zone_1

  tags = merge(local.common_tags, {
    Name = "DefensePro-${local.resource_suffix}-1"
  })
}

resource "aws_instance" "defensepro_2" {
  ami           = var.defensepro_ami_id
  #iam_instance_profile = aws_iam_instance_profile.ec2_s3_access_profile.name
  instance_type = var.instance_type
  user_data = <<-EOT
              #!/bin/bash
              FILE="/mnt/disk/InitialConfig"
              /bin/cat <<EOF > $FILE
              net traffic-encapsulation status set 1
              net traffic-encapsulation protocol set Geneve
              net traffic-encapsulation port set 6081
              net health-check interface set mgmt
              net health-check port set 18000
              net health-check interface set 1
              EOF
  EOT

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.eth0_2.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.eth1_2.id
  }

  availability_zone = local.availability_zone_2

  tags = merge(local.common_tags, {
    Name = "DefensePro-${local.resource_suffix}-2"
  })
}

resource "aws_eip" "defensepro_eip_1" {
  tags = merge(local.common_tags, {
    Name = "DefensePro-EIP-${local.resource_suffix}-1"
  })
}

resource "aws_eip" "defensepro_eip_2" {
  tags = merge(local.common_tags, {
    Name = "DefensePro-EIP-${local.resource_suffix}-2"
  })
}

resource "aws_eip_association" "defensepro_eip_assoc_1" {
  allocation_id        = aws_eip.defensepro_eip_1.id
  network_interface_id = aws_network_interface.eth1_1.id
  depends_on           = [aws_instance.defensepro_1]
}

resource "aws_eip_association" "defensepro_eip_assoc_2" {
  allocation_id        = aws_eip.defensepro_eip_2.id
  network_interface_id = aws_network_interface.eth1_2.id
  depends_on           = [aws_instance.defensepro_2]
}


# Create Internet Gateways
resource "aws_internet_gateway" "customer_vpc_igw" {
  vpc_id = aws_vpc.customer_vpc.id

  tags = merge(local.common_tags, {
    Name = "IGW-Customer-VPC-${local.resource_suffix}"
  })
}

resource "aws_internet_gateway" "scrubbing_vpc_igw" {
  vpc_id = aws_vpc.scrubbing_vpc.id

  tags = merge(local.common_tags, {
    Name = "IGW-Scrubbing-VPC-${local.resource_suffix}"
  })
}

# Create Gateway Load Balancer in Scrubbing VPC
resource "aws_lb" "gateway_lb" {
  internal           = false
  load_balancer_type = "gateway"
  subnets            = [aws_subnet.defensepro_data_subnet_1.id, aws_subnet.defensepro_data_subnet_2.id]

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = merge(local.common_tags, {
    Name = "Gateway-LB-${local.resource_suffix}"
  })
}

# Output to print the ARN of the Gateway Load Balancer
output "gateway_lb_arn" {
  value       = aws_lb.gateway_lb.arn
  description = "The ARN of the Gateway Load Balancer"
}

# Create Target Group for Gateway Load Balancer
resource "aws_lb_target_group" "defensepro_tg" {
  target_type = "ip"
  port        = 6081
  protocol    = "GENEVE"
  vpc_id      = aws_vpc.scrubbing_vpc.id

  health_check {
    protocol            = "TCP"
    port                = "18000"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = "DefensePro-TG-${local.resource_suffix}"
  })
}

# Attach DefensePro instances to the Target Group using their IPs
resource "aws_lb_target_group_attachment" "defensepro_tg_attachment_1" {
  target_group_arn = aws_lb_target_group.defensepro_tg.arn
  target_id        = local.scrubbing_mgmt_ip_1
  port             = 6081
}

resource "aws_lb_target_group_attachment" "defensepro_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.defensepro_tg.arn
  target_id        = local.scrubbing_mgmt_ip_2
  port             = 6081
}

# Create Listener for the Gateway Load Balancer
resource "aws_lb_listener" "gateway_lb_listener" {
  load_balancer_arn = aws_lb.gateway_lb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.defensepro_tg.arn
  }
}


# Create VPC Endpoint Service for the Gateway Load Balancer
resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gateway_lb.arn]

  tags = merge(local.common_tags, {
    Name = "gwlb-endpoint-service-${local.resource_suffix}"
  })
}

# Create VPC Endpoint for the Gateway Load Balancer
resource "aws_vpc_endpoint" "gwlb_endpoint" {
  vpc_id            = aws_vpc.customer_vpc.id
  service_name      = aws_vpc_endpoint_service.gwlb_endpoint_service.service_name
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.glb_endpoint_subnet.id]

  tags = merge(local.common_tags, {
    Name = "gwlb-endpoint-${local.resource_suffix}"
  })
}

# Create a consolidated routing table for the Customer VPC
resource "aws_route_table" "customer_vpc_rt" {
  vpc_id = aws_vpc.customer_vpc.id

  route {
    cidr_block = var.customer_vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.customer_vpc_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "Customer-VPC-RT-${local.resource_suffix}"
  })
}

# Create route to the Scrubbing VPC via the VPC endpoint
resource "aws_route" "route_to_scrubbing_vpc" {
  route_table_id         = aws_route_table.customer_vpc_rt.id
  destination_cidr_block = var.scrubbing_vpc_cidr
  vpc_endpoint_id        = aws_vpc_endpoint.gwlb_endpoint.id
}

# Associate the consolidated routing table with the application and GLB Endpoint subnets
resource "aws_route_table_association" "application_rt_assoc" {
  subnet_id      = aws_subnet.application_subnet.id
  route_table_id = aws_route_table.customer_vpc_rt.id
}

resource "aws_route_table_association" "glb_endpoint_rt_assoc" {
  subnet_id      = aws_subnet.glb_endpoint_subnet.id
  route_table_id = aws_route_table.customer_vpc_rt.id
}

# Routing table for the Scrubbing VPC
resource "aws_route_table" "scrubbing_vpc_default_rt" {
  vpc_id = aws_vpc.scrubbing_vpc.id

  route {
    cidr_block = var.scrubbing_vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.scrubbing_vpc_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "Scrubbing-VPC-Default-RT-${local.resource_suffix}"
  })
}

# Associate the routing table with the DefensePro data subnet
resource "aws_route_table_association" "scrubbing_vpc_default_rt_assoc_1" {
  subnet_id      = aws_subnet.defensepro_data_subnet_1.id
  route_table_id = aws_route_table.scrubbing_vpc_default_rt.id
}

resource "aws_route_table_association" "scrubbing_vpc_default_rt_assoc_2" {
  subnet_id      = aws_subnet.defensepro_data_subnet_2.id
  route_table_id = aws_route_table.scrubbing_vpc_default_rt.id
}

resource "aws_route_table_association" "scrubbing_vpc_mgmt_rt_assoc_1" {
  subnet_id      = aws_subnet.scrubbing_mgmt_subnet_1.id
  route_table_id = aws_route_table.scrubbing_vpc_default_rt.id
}

resource "aws_route_table_association" "scrubbing_vpc_mgmt_rt_assoc_2" {
  subnet_id      = aws_subnet.scrubbing_mgmt_subnet_2.id
  route_table_id = aws_route_table.scrubbing_vpc_default_rt.id
}