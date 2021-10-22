provider "aws" {
  region = "ap-south-1"
  access_key = ""
  secret_key = ""

}


resource "aws_instance" "playground" {
  ami           = "ami-041d6256ed0f2061c"
  instance_type = "t2.micro"

  tags = {
    Name = "playground"
  }

}

resource "aws_vpc" "vpc-playground" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-playground"
  }
}

resource "aws_subnet" "subnet-playground" {
  vpc_id     = aws_vpc.vpc-playground.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-playground"
  }
}
