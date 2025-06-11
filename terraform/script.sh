#!/bin/bash

# Update system and install Docker
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Remove existing network if it exists and create new one
docker network rm mynet12 2>/dev/null || true
docker network create -d bridge --subnet=18.169.237.0/24 mynet12

# Run MySQL container
docker run --name petclinic_db -p 3306:3306 \
  --env MYSQL_USER=petclinic --env MYSQL_ROOT_PASSWORD=root \
  --env MYSQL_DATABASE=petclinic --env MYSQL_PASSWORD=petclinic \
  --env MYSQL_HOST=18.169.237.3 --net mynet12 \
  --ip 18.169.237.3 -d mysql:9.2

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 30

# Run PetClinic application
docker run --net mynet12 --name petclinic_app \
  -p 8080:8080 --env MYSQL_HOST=18.169.237.3 \
  --env MYSQL_PORT=3306 --env MYSQL_URL="jdbc:mysql://18.169.237.3:3306/petclinic" \
  --env MYSQL_DATABASE=petclinic --env MYSQL_USER=petclinic \
  --env MYSQL_PASSWORD=petclinic -it -d anutkarudeha/petclinic_app_run:v1.6

# Show running containers
docker ps -a 