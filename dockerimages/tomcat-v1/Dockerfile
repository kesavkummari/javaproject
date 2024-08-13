# Download Base Image from hub.docker.com
FROM ubuntu

# Environment Variables
ENV TZ=Asia/Kolkata
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

WORKDIR /opt/
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Update, Install & Configure
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk-headless wget curl unzip git && \
    sudo update-alternatives --config java \ 
    sudo update-alternatives --config javac \
    echo "$TZ" > /etc/timezone && \
    echo "$JAVA_HOME" >> /etc/environment && \
    mkdir /opt/tomcat && \
    curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz && \
    tar -xzf apache-tomcat-9.0.93.tar.gz -C /opt/tomcat --strip-components=1 && \
    rm apache-tomcat-9.0.93.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Change Directory
WORKDIR /opt/tomcat

# User Management and Roles
COPY tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
COPY context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
COPY context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
COPY tomcat.service /etc/systemd/system/tomcat.service

WORKDIR /opt/tomcat/webapps

# Download Artifact from remote location
RUN aws s3 cp s3://8amcloudbinary/c3opslmsapp.war 
# RUN curl -O -L https://github.com/kesavkummari/javaproject/blob/main/c3opslms.war

# Port Configuration
#RUN sed -i 's/port="8080"/port="80"/' /opt/tomcat/conf/server.xml

# Enable WebServer Port i.e. HTTP 80/TCP
EXPOSE 8080

# Execute WebServer
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
