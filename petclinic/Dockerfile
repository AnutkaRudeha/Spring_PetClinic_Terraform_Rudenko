FROM amazonlinux:2023
# docker build -t anutkarudeha/petclinic-app:v1 .
# docker build -t anutkarudeha/petclinic_app_build:v1 -f petclinic_app_build .

RUN yum update -y && yum install -y git java-17-amazon-corretto \
    && yum clean all && \
    rm -rf /var/cache/yumS

# ENTRYPOINT ["/bin/bash", "-c", "/scripts/test.sh"]
# CMD ["/bin/bash", "-c", "/scripts/test.sh"]

# docker run -it -v //c/test/getting-started-app/demo2/artifact:/artifact -v //c/test/getting-started-app/demo2/scripts:/scripts anutkarudeha/petclinic_app_build:v1  /bin/bashі

FROM public.ecr.aws/bitnami/java:latest
VOLUME /tmp
ADD target/spring-petclinic-2.3.0.jar app.jar
EXPOSE 80
RUN apt-get update
RUN apt-get -y install awscli
ENTRYPOINT env spring.datasource.password=$(aws ssm get-parameter --name /database/password --with-decrypt --region $AWS_REGION | grep Value | cut -d '"' -f4) java -Djava.security.egd=file:/dev/./urandom -jar /app.jar