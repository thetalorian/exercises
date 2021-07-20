# Code to greate the Autoscaling Group and related
# resources for the buildreader application.

resource "aws_security_group" "buildreader_app" {
    name        = "buildreader_app"
    description = "Access permissions for buildreader application"
    vpc_id      = data.aws_vpc.assigned.id

    tags = {
        Name = "buildreader_app"
    }
}

resource "aws_security_group_rule" "ssh_access" {
    security_group_id = aws_security_group.buildreader_app.id
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_access" {
    security_group_id = aws_security_group.buildreader_app.id
    type                     = "ingress"
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    source_security_group_id = aws_security_group.buildreader_elb.id
}

resource "aws_security_group_rule" "egress" {
    security_group_id = aws_security_group.buildreader_app.id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}

resource "aws_key_pair" "build_reader_access_key" {
    key_name   = var.access_key_name
    public_key = var.access_public_key
}

resource "aws_launch_configuration" "buildreader_app" {
    name_prefix = "buildreader-app"
    image_id = data.aws_ami.buildreader.id
    instance_type = "t3.micro"
    key_name = aws_key_pair.build_reader_access_key.key_name
    security_groups = [aws_security_group.buildreader_app.id]
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "buildreader_app" {
    name = "buildreader-app"
    launch_configuration = aws_launch_configuration.buildreader_app.id
    availability_zones = data.aws_availability_zones.allzones.names
    min_size = 1
    max_size = 1

    load_balancers = [aws_elb.buildreader.id]
    health_check_type = "ELB"

    instance_refresh {
        strategy = "Rolling"
    }

    lifecycle {
        create_before_destroy = true
    }
}

// resource "aws_launch_template" "foobar" {
//   name_prefix   = "foobar"
//   image_id      = "ami-1a2b3c"
//   instance_type = "t2.micro"
// }

// resource "aws_autoscaling_group" "bar" {
//   availability_zones = ["us-east-1a"]
//   desired_capacity   = 1
//   max_size           = 1
//   min_size           = 1

//   launch_template {
//     id      = aws_launch_template.foobar.id
//     version = "$Latest"
//   }
// }



// resource "aws_instance" "build_reader_compute" {
//     ami           = data.aws_ami.buildreader.id
//     instance_type = "t3.micro"
//     subnet_id = var.assigned_subnet
//     vpc_security_group_ids = [aws_security_group.buildreader_app.id]
//     key_name = aws_key_pair.build_reader_access_key.key_name

//     tags = {
//         Name = "BuildReader"
//     }
// }
