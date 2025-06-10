$port
#!/bin/bash

docker run hello-world
docker network rm mynet12 && docker network create -d bridge --subnet=18.169.237.0/24 mynet12
docker run --name petclinic_db -p 3306:3306 --env MYSQL_USER=petclinic --env MYSQL_DATABASE=petclinic --env MYSQL_PASSWORD=1234567890 --env MYSQL_HOST=18.169.237.3 --net mynet12 -d mysql:8.4.3
docker run --net mynet12 --name petclinic_app -p 8080:8080 --env MYSQL_HOST=18.169.237.3 --env MYSQL_PORT=3306:3306 --env MYSQL_URL=jdbc:mysql://18.169.237.3:3306/petclinic --env MYSQL_DATABASE=petclinic --env MYSQL_USER=petclinic --env MYSQL_PASSWORD=1234567890 -d anutkarudeha/petclinic_app_run:v1.5


mysql -u petclinic -p1234567890 -h 18.169.237.3 petclinic 


#!/bin/bash

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Create custom Docker network
docker network create --subnet=18.169.237.0/24 mynet12

# Run MySQL container
docker run --name petclinic_db \
  -p 3306:3306 \
  --env MYSQL_USER=petclinic \
  --env MYSQL_ROOT_PASSWORD=1234567890 \
  --env MYSQL_DATABASE=petclinic \
  --env MYSQL_PASSWORD=1234567890 \
  --net mynet12 \
  --ip 18.169.237.3 \
  -d \
  mysql:8.4.3

# Wait for MySQL to be ready
sleep 30

# Run PetClinic application
docker run --net mynet12 \
  --name petclinic_app \
  -p 8080:8080 \
  --env MYSQL_HOST=18.169.237.3 \
  --env MYSQL_PORT=3306 \
  --env MYSQL_URL=jdbc:mysql://18.169.237.3:3306/petclinic \
  --env MYSQL_DATABASE=petclinic \
  --env MYSQL_USER=petclinic \
  --env MYSQL_PASSWORD=1234567890 \
  -d \
  anutkarudeha/petclinic_app_run:v1.5