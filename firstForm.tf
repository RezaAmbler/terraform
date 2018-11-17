provider "aws" {
	region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-6cd6f714"
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
  	command = "yum install httpd;"
  }
}

resource "aws_eip" "example_ip" {
	instance = "${aws_instance.example.id}"
}