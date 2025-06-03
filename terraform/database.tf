# Security group for the database
resource "aws_security_group" "db" {
  name        = "${var.stack}-db-sg"
  description = "Security group for MySQL database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "Allow MySQL access from application"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.stack}-db-sg"
    Environment = var.environment
  }
}

# EC2 instance for MySQL
resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_id              = aws_subnet.private[0].id

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              yum update -y
              
              # Install MySQL
              yum install -y mysql-server
              systemctl enable mysqld
              systemctl start mysqld
              
              # Get MySQL root password
              MYSQL_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
              
              # Create database and user
              mysql -u root -p"$MYSQL_ROOT_PASSWORD" --connect-expired-password <<-EOSQL
                ALTER USER 'root'@'localhost' IDENTIFIED BY '${var.db_password}';
                CREATE DATABASE petclinic;
                CREATE USER 'petclinic'@'%' IDENTIFIED BY '${var.db_password}';
                GRANT ALL PRIVILEGES ON petclinic.* TO 'petclinic'@'%';
                FLUSH PRIVILEGES;
              EOSQL
              
              # Configure MySQL to accept remote connections
              sed -i 's/bind-address = 127.0.0.1/bind-address = 0.0.0.0/' /etc/my.cnf
              systemctl restart mysqld
              EOF

  tags = {
    Name        = "${var.stack}-db"
    Environment = var.environment
  }
}

# Store database password in SSM Parameter Store
resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.stack}/db/password"
  description = "Database password for PetClinic"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name        = "${var.stack}-db-password"
    Environment = var.environment
  }
} 