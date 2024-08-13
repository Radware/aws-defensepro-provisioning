# DefensePro AWS Terraform Project

This project uses Terraform to provision a DefensePro setup in AWS. The setup includes creating multiple VPCs, subnets, security groups, network interfaces, and EC2 instances configured with DefensePro, along with a Gateway Load Balancer for scrubbing traffic.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Usage](#usage)
3. [Project Structure](#project-structure)
4. [Variables](#variables)
5. [Outputs](#outputs)
6. [License](#license)

## Prerequisites

- Terraform (v1.0.0 or later)
- AWS CLI configured with appropriate permissions
- Access to the DefensePro AMI ID
- SSH access to the created instances (whitelisted IP)

## Usage

1. **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2. **Initialize the Terraform workspace**:
    ```bash
    terraform init
    ```

3. **Plan the Infrastructure**:
    ```bash
    terraform plan
    ```

4. **Apply the Configuration**:
    ```bash
    terraform apply
    ```

5. **Destroy the Infrastructure** (when no longer needed):
    ```bash
    terraform destroy
    ```

## Project Structure

- `main.tf`: The main Terraform file that includes all the resources and configurations.
- `variables.tf`: Defines all the input variables for the project.
- `outputs.tf`: Defines the outputs for the project.
- `defensepro-setup.sh`: A script that will be uploaded to an S3 bucket and used for configuring the DefensePro instances.
- `README.md`: This file, providing an overview and instructions for using the project.

## Variables

| Name                          | Type   | Default         | Description                                                        |
|-------------------------------|--------|-----------------|--------------------------------------------------------------------|
| `aws_region`                  | string | `us-east-1`     | The AWS region to deploy in                                        |
| `customer_vpc_cidr`           | string | `10.1.0.0/16`   | The CIDR block for the Customer VPC                                 |
| `scrubbing_vpc_cidr`          | string | `10.10.0.0/16`  | The CIDR block for the Scrubbing VPC                                |
| `application_subnet_cidr`     | string | `10.1.2.0/24`   | The CIDR block for the Application Subnet in Customer VPC          |
| `glb_endpoint_subnet_cidr`    | string | `10.1.111.0/24` | The CIDR block for the GLB Endpoint Subnet in Customer VPC         |
| `scrubbing_mgmt_subnet_cidr_1`| string | `10.10.1.0/24`  | The CIDR block for the Management Subnet 1 in Scrubbing VPC        |
| `scrubbing_mgmt_subnet_cidr_2`| string | `10.10.4.0/24`  | The CIDR block for the Management Subnet 2 in Scrubbing VPC        |
| `defensepro_data_subnet_cidr_1`| string | `10.10.2.0/24` | The CIDR block for the Data Subnet 1 in Scrubbing VPC              |
| `defensepro_data_subnet_cidr_2`| string | `10.10.3.0/24` | The CIDR block for the Data Subnet 2 in Scrubbing VPC              |
| `availability_zone_suffix_1`  | string | `a`             | The first availability zone suffix to use                          |
| `availability_zone_suffix_2`  | string | `b`             | The second availability zone suffix to use                         |
| `defensepro_ami_id`           | string | N/A             | The AMI ID for DefensePro (must be provided)                       |
| `instance_type`               | string | `r5dn.large`    | The instance type to use for DefensePro                            |
| `admin_computer_network_for_ssh`| string | `94.188.248.75/32` | Your IP address for SSH access                                  |
| `deployment_index`            | string | N/A             | A number to include in resource names                              |
| `project_name`                | string | `MyProject`     | The name of the project                                            |

## Outputs

| Name                   | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `customer_vpc_id`      | The ID of the Customer VPC                                                   |
| `scrubbing_vpc_id`     | The ID of the Scrubbing VPC                                                  |
| `application_subnet_id`| The ID of the Application Subnet                                             |
| `glb_endpoint_subnet_id`| The ID of the GLB Endpoint Subnet                                           |
| `elastic_ip_dp_1`      | The Elastic IP for DefensePro 1                                              |
| `elastic_ip_dp_2`      | The Elastic IP for DefensePro 2                                              |
| `deployment_message`   | A deployment message summarizing the DefensePro instances' details and IPs   |
| `gateway_lb_arn`       | The ARN of the Gateway Load Balancer                                         |
