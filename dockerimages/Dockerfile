# Download Base Image from hub.docker.com
FROM ubuntu

# Execute Commands
RUN apt-get update

# Environment Variables
ENV TZ=Asia/Kolkata

# Update Environment Variable unto File 
RUN echo $TZ > /etc/timezone

# Download, Install & Configure 
RUN apt-get update 

WORKDIR /opt/
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

#RUN apt-get install openjdk-17-jdk -y 
RUN apt-get install -y openjdk-17-jdk-headless
RUN update-alternatives --config java 
RUN update-alternatives --config javac
RUN apt-get install wget -y 
RUN apt-get install curl -y 
RUN apt-get install unzip -y 
RUN apt-get install git -y 

# Environment Variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

# Update Environment Variable unto File 
RUN echo "$JAVA_HOME" >> /etc/environment

RUN cat /etc/environment 

# Cleanup APT Command 
RUN apt-get clean

# Create a Folder For Tomcat
RUN mkdir /opt/tomcat/

# Change Directory 
WORKDIR /opt/

# Download Tomcat Binary File 
RUN curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz

# Extract the Tomcat Binary File 
RUN cd /opt/ && tar -xzf apache-tomcat-9.0.93.tar.gz && rm apache-tomcat-9.0.93.tar.gz

RUN pwd

# Move the content to Tomcat Home Directory 
RUN mv apache-tomcat-9.0.93/* /opt/tomcat/.

# List User Mgmt File 
RUN ls -lrta /opt/tomcat/conf/tomcat-users.xml

# Take Tomcat Configuration as backup 
RUN cp /opt/tomcat/conf/tomcat-users.xml "/opt/tomcat/conf/tomcat-users.xml_$(date +%F_%R)"

# To delete last line and which contains </tomcat-users>
RUN sed -i '$d' /opt/tomcat/conf/tomcat-users.xml

# Add User & Attach Roles to Tomcat
RUN echo '<role rolename="manager-gui"/>'  >> /opt/tomcat/conf/tomcat-users.xml
RUN echo '<role rolename="manager-script"/>' >> /opt/tomcat/conf/tomcat-users.xml
RUN echo '<role rolename="manager-jmx"/>'    >> /opt/tomcat/conf/tomcat-users.xml
RUN echo '<role rolename="manager-status"/>' >> /opt/tomcat/conf/tomcat-users.xml

RUN echo '<role rolename="admin-gui"/>'     >> /opt/tomcat/conf/tomcat-users.xml
RUN echo '<role rolename="admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml

RUN echo '<user username="admin" password="redhat@123" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>' >> /opt/tomcat/conf/tomcat-users.xml

# Add XML Closing Element to the file i.e. </tomcat-users>
RUN echo "</tomcat-users>" >> /opt/tomcat/conf/tomcat-users.xml

RUN echo '<?xml version="1.0" encoding="UTF-8"?>' > /opt/tomcat/webapps/manager/META-INF/context.xml 
RUN echo '<Context antiResourceLocking="false" privileged="true" >' >> /opt/tomcat/webapps/manager/META-INF/context.xml 
RUN echo '</Context>' >> /opt/tomcat/webapps/manager/META-INF/context.xml 

RUN echo '<?xml version="1.0" encoding="UTF-8"?>' > /opt/tomcat/webapps/host-manager/META-INF/context.xml 
RUN echo '<Context antiResourceLocking="false" privileged="true" >' >> /opt/tomcat/webapps/host-manager/META-INF/context.xml 
RUN echo '</Context>' >> /opt/tomcat/webapps/host-manager/META-INF/context.xml 

WORKDIR /opt/tomcat/webapps

# Upload Artifact From Your Local Path 
# COPY ./devops.war /opt/tomcat/webapps/

# Download Artifact from remote location
RUN aws s3 cp s3://8amcloudbinary/c3opslmsapp.war 
# RUN curl -O -L https://github.com/kesavkummari/javaproject/blob/main/c3opslms.war

RUN echo '[Unit]' > /etc/systemd/system/tomcat.service
RUN echo 'Description=Apache Tomcat Web Application Container' >> /etc/systemd/system/tomcat.service
RUN echo 'After=network.target' >> /etc/systemd/system/tomcat.service 
RUN echo '[Service]' >> /etc/systemd/system/tomcat.service
RUN echo 'Type=forking' >> /etc/systemd/system/tomcat.service
RUN echo 'Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64' >> /etc/systemd/system/tomcat.service 
RUN echo 'Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid' >> /etc/systemd/system/tomcat.service  
RUN echo 'Environment=CATALINA_HOME=/opt/tomcat' >> /etc/systemd/system/tomcat.service 
RUN echo 'Environment=CATALINA_BASE=/opt/tomcat' >> /etc/systemd/system/tomcat.service 
RUN echo 'Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'' >> /etc/systemd/system/tomcat.service 
RUN echo 'Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'' >> /etc/systemd/system/tomcat.service 

RUN echo 'ExecStart=/opt/tomcat/bin/startup.sh' >> /etc/systemd/system/tomcat.service 
RUN echo 'ExecStop=/opt/tomcat/bin/shutdown.sh' >> /etc/systemd/system/tomcat.service 

RUN echo 'User=root' >> /etc/systemd/system/tomcat.service 
RUN echo 'Group=root' >> /etc/systemd/system/tomcat.service 
RUN echo 'UMask=0007' >> /etc/systemd/system/tomcat.service 
RUN echo 'RestartSec=10' >> /etc/systemd/system/tomcat.service 
RUN echo 'Restart=always' >> /etc/systemd/system/tomcat.service 

RUN echo '[Install]' >> /etc/systemd/system/tomcat.service 
RUN echo 'WantedBy=multi-user.target' >> /etc/systemd/system/tomcat.service 

#RUN sed -i 's/port="8080"/port="80"/' /opt/tomcat/conf/server.xml

# Enable WebServer Port i.e. HTTP 80/TCP
EXPOSE 8080

# Execute WebServer
CMD ["/opt/tomcat/bin/catalina.sh", "run"]





