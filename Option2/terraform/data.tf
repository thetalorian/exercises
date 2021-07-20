data "aws_vpc" "assigned" {
    id = var.assigned_vpc
}

data "aws_availability_zones" "allzones" {}

data "aws_ami" "buildreader" {
    most_recent = true

    filter {
        name   = "tag:Name"
        values = ["BuildReader"]
    }

    owners = ["self"]
}

data "aws_route53_zone" "deploy" {
    name = var.deploy_domain
}