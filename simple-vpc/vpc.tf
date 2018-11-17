provider "aws" { 
  region = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.200.0/24"


  tags {
    Name = "test vpc"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.vpc.id}"
}