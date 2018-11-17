provider "aws" {
	region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-6cd6f714"
  instance_type = "t2.nano"
  key_name = "Reza-Oregon-Key"

  vpc_security_group_ids = "sg-0b091ac3f64ff7114"

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
  	command = "yum update -y;"
  }
}

resource "aws_eip" "example_ip" {
	instance = "${aws_instance.example.id}"
}