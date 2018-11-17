provider "aws" {
	region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-6cd6f714"
  instance_type = "t2.nano"
}

resource "aws_eip" "example_ip" {
	instance = "${aws_instance.example.id}"
}