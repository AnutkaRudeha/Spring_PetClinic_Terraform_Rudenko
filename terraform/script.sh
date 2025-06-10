$port
#!/bin/bash

docker run hello-world

docker network rm mynet12 && docker network create -d bridge --subnet=18.169.237.0/24 mynet12

docker run --name petclinic_db -p 3306:3306 \
  --env MYSQL_USER=petclinic --env MYSQL_ROOT_PASSWORD=root \
  --env MYSQL_DATABASE=petclinic --env MYSQL_PASSWORD=petclinic \
  --env MYSQL_HOST=18.169.237.3 --net mynet12 \
  --ip 18.169.237.3 -d mysql:9.2

docker run --net mynet12 --name petclinic_app \
  -p 8080:8080 --env MYSQL_HOST=18.169.237.3 \
  --env MYSQL_PORT=3306 --env MYSQL_URL="jdbc:mysql://18.169.237.3:3306/petclinic" \
  --env MYSQL_DATABASE=petclinic --env MYSQL_USER=petclinic \
  --env MYSQL_PASSWORD=petclinic -it -d anutkarudeha/petclinic_app_run:v1.6
\
docker ps -a
# mysql -u petclinic -ppetclinic -h 18.169.237.3 petclinic 