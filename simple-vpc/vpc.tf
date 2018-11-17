provider "aws" { 
  region = "us-west-2"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-west-2"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        eu-west-1 = "ami-f1810f86" # ubuntu 14.04 LTS
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "192.168.200.0/24"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "192.168.200.0/25"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "192.168.200.128/25"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "test vpc"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.vpc.id}"
}

resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "nat_sg" {
	name = "test_vpc_nat"
	description "a test nat gateway for the private subnet"

	egress {
		from_port = -1
		to_port = -1
		protocol = "any"
		cidr_block = ["0.0.0.0/0"]
	}	

vpc_id = "${aws_vpc.vpc.id}"

	tags {
		Name = "Test NAT SG"
	}
}

# //implement NAT Gateway here, not the example's nat instance

resource "aws_subnet" "us-west-2a-public" {
	vpc_id = "${aws_vpc.vpc.id}"

	cidr_block = "${var.public_subnet_cidr}"
	availability_zone = "us-west-2a"

	tags {
		Name = "Public Subnet Test VPC"
	}
}

resource "aws_route_table" "us-west-2a-public" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}

	tags {
		Name = "Test Public Subnet"
	}
}

resource "aws_route_table_association" "us-west-2a-public" {
	subnet_id = "${aws_subnet.us-west-2a-public.id"
	route_table_id = "${aws_route_table.us-west-2a-public.id}"
}

resource "aws_subnet" "us-west-2a-private" {
	vpc_id = "${aws_vpc.vpc.id}"

	cidr_block = "${var.private_subnet_cidr"
	availability_zone = "us-west-2a"

	tags {
		Name = "Private Subnet Test VPC"
	}
}

resource "aws_route_table" "us-west-2a-private" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
	}

	tags {
		Name = "Private Subnet"
	}
}

resource "aws_route_table_association" "us-west-2a-private" {
	subnet_id = "${aws_subnet.us-west-2a-private.id}"
	route_table_id = "${aws_route_table.us-west-2a-private.id}"
}