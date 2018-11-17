provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "../../"

  name = "simple-example"

  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}

resource "aws_instance" "example" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.nano"
  key_name = "Reza-Oregon-Key"
  vpc_id = "${module.vpc.id}"

  vpc_security_group_ids = ["sg-0a9164668ad9cc0dd"]

  tags { 
    Name = "Terraform Test"
  }

  volume_tags {
    Name = "Terraform Test"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > /tmp/ip_address.txt"
  }

  provisioner "local-exec" {
    command = "sudo /usr/bin/yum install httpd;"
  }
}