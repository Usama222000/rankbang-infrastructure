# emumba-sample-app-Infrastructure

This Terraform project sets up the infrastructure for the **rankbang application**, including the VPC, Security Groups, EKS Cluster, and integrates 

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Modules Overview](#modules-overview)

## Prerequisites

Before using this Terraform project, ensure the following tools are installed:

- [Terraform](https://www.terraform.io/) (version 1.1+)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with the correct AWS credentials)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (to interact with EKS)

Additionally, the following AWS resources should be available:

- An AWS account with appropriate IAM permissions to create VPC, Security Groups, EKS, and other required resources.

## Project Structure

```plaintext
├── config
│   └── devtfvars              # Configuration values for the dev 
├── modules
│   ├── vpc                    # VPC module
│   ├── security_group         # Security Group module
│   └── eks                    # EKS module
├── main.tf                    # Main Terraform configuration file
├── outputs.tf                 # Terraform outputs
└── README.md                  # Project documentation
```
## deploy the infrastructure

1. Initialize terraform

   ```bash
   terraform init
   ````
2. Plan to see the resource creation terraform

   ```bash
   terraform plan --var-file=./config/dev.tfvars
   ````
3. finally apply the terraform

   ```bash
   terraform apply --var-file=./config/dev.tfvars
   ````