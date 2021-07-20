variable "aws_region" {
    description = "AWS regoin to host application"
    default = "us-east-1"
}

variable "assigned_subnet" {
    description = "AWS Subnet to host application"
}

variable "assigned_vpc" {
    description = "AWS VPC to host application"
}

variable "access_key_name" {
    description = "Name to use for the access key"
}

variable "access_public_key" {
    description = "Public key for the access key pair"
}

variable "deploy_domain" {
    description = "Domain name for DNS entry"
}

variable "deploy_subdomain" {
    description = "Subdomain name for DNS entry"
}