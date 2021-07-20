#!/bin/bash
cd buildreader
packer build buildreader.pkr.hcl
cd ../terraform
terraform apply -auto-approve