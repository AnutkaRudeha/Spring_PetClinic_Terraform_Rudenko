FROM amazonlinux:2023

ARG APPUSER=petclinic 
ENV APP_USER=$APPUSER

RUN yum update -y && yum install -y java-17-amazon-corretto && yum install -y mariadb105-server && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN yum -y install python3 \
    python3-pip \
    shadow-utils

RUN mkdir run_java_project
COPY ./spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar /run_java_project

RUN echo -e $APPUSER 
RUN useradd $APPUSER && \
    chown $APPUSER /run_java_project/spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar 

USER $APPUSER
WORKDIR /run_java_project

EXPOSE 8080

ENTRYPOINT ["java","-Dspring.profiles.active=mysql","-jar","/run_java_project/spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar"]
# ENTRYPOINT ["java","-jar","/run_java_project/spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar"]