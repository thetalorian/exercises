# Code to create the load balancer and related
# resources for the buildreader application.

resource "aws_security_group" "buildreader_elb" {
    name        = "buildreader_elb"
    description = "Access permissions for buildreader elb"
    vpc_id      = data.aws_vpc.assigned.id

    tags = {
        Name = "buildreader_elb"
    }
}

resource "aws_security_group_rule" "web_access" {
    security_group_id = aws_security_group.buildreader_elb.id
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_egress" {
    security_group_id = aws_security_group.buildreader_elb.id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}

resource "aws_elb" "buildreader" {
    name = "buildreader"
    availability_zones = data.aws_availability_zones.allzones.names
    security_groups = [aws_security_group.buildreader_elb.id]

    listener {
        instance_port = 8080
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:8080/"
        interval = 30
    }

    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400

    tags = {
        Name = "BuildReader"
    }
}

resource "aws_route53_record" "buildreader" {
  zone_id = data.aws_route53_zone.deploy.zone_id
  name    = "${var.deploy_subdomain}.${var.deploy_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elb.buildreader.dns_name]
}
