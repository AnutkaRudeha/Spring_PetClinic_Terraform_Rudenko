# Security group for the application
resource "aws_security_group" "app" {
  name        = "${var.app_name}-app-sg"
  description = "Security group for PetClinic application"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App port"
  }

ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "App 2port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-app-sg"
    Environment = var.environment
  }
}

# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.app_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-ec2-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.app_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/scripts/script.sh", { version = var.app_version, port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })

  tags = {
    Name        = "${var.app_name}-app"
    Environment = var.environment
  }
}

# Output the application URL
output "app_url" {
  value = "http://${aws_instance.app.public_ip}:${var.app_port}"
  description = "URL for the PetClinic application"
} 

