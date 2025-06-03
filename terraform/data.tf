data "aws_caller_identity" "current" {}

data "aws_ecr_repository" "image_repo" {
  name = "${var.stack}-petclinic"
}

data "aws_ssm_parameter" "dbpassword" {
  name = "/${var.stack}/db/password"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
} 