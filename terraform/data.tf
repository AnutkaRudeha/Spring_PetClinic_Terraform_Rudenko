# # Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["926680503007"]

  filter {
    name   = "name"
    values = ["test-app-app"]
  }

  # filter {
  #   name   = "virtualization-type"
  #   values = ["hvm"]
  # }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {} 