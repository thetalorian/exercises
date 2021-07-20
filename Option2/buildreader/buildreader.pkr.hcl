packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "buildreader"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
      Name = "BuildReader"
      OS_Version = "Ubuntu"
      Release = "Latest"
      Base_AMI_Name = "{{ .SourceAMIName }}"
      Extra = "{{ .SourceAMITags.TagName }}"
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]
  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    inline = [
      "sleep 30",
      "apt-add-repository ppa:ansible/ansible -y",
      "/usr/bin/apt-get update",
      "/usr/bin/apt-get -y install ansible",
      "mkdir /home/ubuntu/buildreader",
      "chown ubuntu:ubuntu /home/ubuntu/buildreader"
    ]
  }

  provisioner "file" {
    source      = "./"
    destination = "/home/ubuntu/buildreader"
  }

  provisioner "ansible-local" {
    playbook_file   = "./buildreader-playbook.yml"
  }
}