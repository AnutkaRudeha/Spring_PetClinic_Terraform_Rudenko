# Security group for the application
resource "aws_security_group" "app" {
  name        = "${var.stack}-app-sg"
  description = "Security group for PetClinic application"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow application traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.stack}-app-sg"
    Environment = var.environment
  }
}

# IAM role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "${var.stack}-ec2-role"

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
    Name        = "${var.stack}-ec2-role"
    Environment = var.environment
  }
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.stack}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# IAM policy for EC2 to pull from ECR
resource "aws_iam_role_policy" "ec2_ecr_policy" {
  name = "${var.stack}-ec2-ecr-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# EC2 instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = aws_subnet.public[0].id

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install Docker
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              
              # Install AWS CLI
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              yum install -y unzip
              unzip awscliv2.zip
              ./aws/install
              
              # Login to ECR
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
              
              # Pull and run the container
              docker pull anutkarudeha/petclinic:app-run-v1.5
              docker run -d \
                --name petclinic \
                -p ${var.app_port}:${var.app_port} \
                -e SPRING_PROFILES_ACTIVE=mysql \
                -e MYSQL_URL=jdbc:mysql://${aws_instance.db.private_ip}:${var.db_port}/petclinic \
                -e MYSQL_USER=petclinic \
                -e MYSQL_PASS=${var.db_password} \
                anutkarudeha/petclinic:app-run-v1.5
              EOF

  tags = {
    Name        = "${var.stack}-app"
    Environment = var.environment
  }

  depends_on = [aws_instance.db]
}

# Output the application URL
output "app_url" {
  value = "http://${aws_instance.app.public_ip}:${var.app_port}"
  description = "URL for the PetClinic application"
} 