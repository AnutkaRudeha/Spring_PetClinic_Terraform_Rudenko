terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c76bd4bd302b30ec"
  instance_type = "t2.micro"

  tags = {
    Name  = "test-app-01"
    value = "created by terraform"
  }
}
