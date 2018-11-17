variable "region" {
  default = "us-west-2"
}

provider "aws" {
	region = "${var.region}"
}

variable "amis" {
	type = "map"
	default = {
		"us-west-2" = "ami-6cd6f714"
		"us-east-1" = "ami-b374d5a5"
	}
}

resource "aws_instance" "example" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.nano"
  key_name = "Reza-Oregon-Key"

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

resource "aws_eip" "example_ip" {
	instance = "${aws_instance.example.id}"
}

output "ip" {
	value = "${aws_eip.example_ip.public_ip}"
}