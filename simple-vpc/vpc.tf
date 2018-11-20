# Define the provider, this can be one of a long list of Cloud providers
# AWS , Azure, GCP, VMWare, etc..
# list here : https://www.terraform.io/docs/providers/
provider "aws" { 
  region = "us-west-2"
}

# BEGIN VARIABLES
# Variables to be used through the TF file
# These can also be defined in another file and passed into
# the terraform file for consumption
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
# END VARIABLES

# Here we have multiple resource blocks. 
# This is where the rubber meets the road, and we actually 
# start deploying resources into the Cloud Provider (AWS)
resource "aws_vpc" "vpc" {
  cidr_block       = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "test vpc"
  }
}

resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_security_group" "nat_sg" {
	name = "test_vpc_nat"
	description = "a test nat gateway for the private subnet"

	egress {
		from_port = 0
		to_port = 0
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}	

vpc_id = "${aws_vpc.vpc.id}"

	tags {
		Name = "Test NAT SG"
	}
}

# EIP needed for the NAT Gateway
resource "aws_eip" "ngw-eip" {
	vpc = true
	# VPC ID ?
}

# //implement NAT Gateway here, not the example's nat instance (deprecated)
resource "aws_nat_gateway" "ngw" {
	allocation_id  = "${aws_eip.ngw-eip.id}"
	subnet_id      = "${aws_subnet.us-west-2a-public.id}"
}

# Subnet definition, calling a variable from the begining
resource "aws_subnet" "us-west-2a-public" {
	# VPC ID taken from the terraform state file
	# This ID is only available once Terraform has made the VPC
	# Terraform handles the event ordering
	vpc_id = "${aws_vpc.vpc.id}"

	# variable defined at the top
	cidr_block = "${var.public_subnet_cidr}"
	availability_zone = "us-west-2a"

	tags {
		Name = "Public Subnet Test VPC"
	}
}

# Create a Route Table, assign it to the VPC ID
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

# Here we associate the Subnet from above with the reoute table above
# Subnet : us-west-2a-public 
# Route T: us-west-2a-public
resource "aws_route_table_association" "us-west-2a-public" {
	subnet_id = "${aws_subnet.us-west-2a-public.id}"
	route_table_id = "${aws_route_table.us-west-2a-public.id}"
}

# Private Subnet
resource "aws_subnet" "us-west-2a-private" {
	vpc_id = "${aws_vpc.vpc.id}"

	cidr_block = "${var.private_subnet_cidr}"
	availability_zone = "us-west-2a"

	tags {
		Name = "Private Subnet Test VPC"
	}
}

# Route table for private subnet
resource "aws_route_table" "us-west-2a-private" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.ngw.id}"
	}

	tags {
		Name = "Private Subnet"
	}
}

# Associate the Subnet and Route Table together
# Subnet : us-west-2a-private
# Route T: us-west-2a-private
# Obviously we would have better / more generic names for some of these
# This is just a quick example
resource "aws_route_table_association" "us-west-2a-private" {
	subnet_id = "${aws_subnet.us-west-2a-private.id}"
	route_table_id = "${aws_route_table.us-west-2a-private.id}"
}

# This presents nice output to the user / consumer once
# terraform has finished the job and has all the state information
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.vpc.id}"
}