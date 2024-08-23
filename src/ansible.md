#### What is Ansible?

    - Ansible is an open source automation platform used for configuration management, application deployment, and task automation. 
    
    - It is designed to help users automate routine tasks so that they can spend more time on complex and important activities. 
    
    - Ansible uses an agentless architecture, which means there is no need to install any software on the managed hosts. 
    
    - This allows Ansible to be used for managing both on-premises and cloud-based systems.

    - https://devopsbootcamp.osuosl.org/configuration-management.html#id3

#### Here's a table comparing Puppet, Chef, Saltstack, and Ansible based on their table output features:

| Feature | Puppet | Chef | Saltstack | Ansible |
|---------|--------|------|-----------|---------|
| Declarative	| Yes | Yes | Yes | Yes |
| Imperative	| No | Yes | Yes | Yes |
| Agentless	| No	| No | No | Yes |
| Agent-based	| Yes | Yes | Yes | No |
| Configuration as Code	| Yes | Yes | Yes | Yes |
| Push-based	| No | No | Yes | Yes |
| Pull-based	| Yes | Yes | No	| No |
| Idempotent	| Yes | Yes | Yes | Yes |
| Easy to Learn	| No | No | No | Yes |
| Community Support	| Yes | Yes | Yes |	Yes |


    - In summary, all four tools have table output features, but there are some differences in their approach and functionality. 
    
    - Puppet, Chef, Saltstack, and Ansible all support declarative configuration, with Chef and Saltstack also supporting imperative configuration. 
    
    - Saltstack and Ansible are agentless, while Puppet and Chef require an agent to be installed on the target hosts. 
    
    - All four tools support configuration as code and push-based deployment, but only Saltstack supports pull-based deployment. 
    
    - All four tools are idempotent and have strong community support, but Ansible is considered easier to learn compared to Puppet, Chef, and Saltstack.

#### Key Things Of Ansible
    1. Ansible is an open-source automation platform that enables users to configure systems, deploy applications, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.

    2. Ansible uses an easy-to-learn language called YAML to write playbooks, which are declarative files that define the desired state of a system.

    3. Ansible Tower is the commercial version of Ansible, which provides a web-based interface, REST API, and CLIs for managing and monitoring Ansible tasks.

    4. Ansible can be used to configure and manage servers, network devices, and cloud services, as well as to deploy applications and orchestrate complex IT workflows.

    5. Ansible is agentless, meaning it does not require any additional software to be installed on the managed nodes.

#### Example Playbooks

    Syntax Check:
        $ ansible-playbook --syntax-check web.yml


    Preview a Playbook:
        $ ansible-playbook --check web.yml


    Execute a Playbook:
        $ ansible-playbook web.yml

#### STEP-1 : Launch 2 EC2 Instance i.e. Ubuntu

```

AZ-1a

aws ec2 run-instances \
--image-id "ami-053b0d53c279acc90" \ 
--count 2 \
--instance-type t2.micro \
--key-name "ansible_nv" \
--security-group-ids "sg-07a189e920fd10fee" \
--subnet-id "subnet-0385704f22e343550" \
--iam-instance-profile Name=8amSSMEC2 \
--user-data file://ansible_install.txt \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ansible-controller},{Key=Environment,Value=Development},{Key=ProjectName,Value=CloudBinary},{Key=ProjectID,Value=20221003},{Key=EmailID,Value=admin@cloudbinary.io},{Key=MobileNo,Value=+919100073006}]'

aws ec2 run-instances --image-id "ami-053b0d53c279acc90" --count 1 --instance-type t2.micro --key-name "ansible_nv" --security-group-ids "sg-07a189e920fd10fee" --subnet-id "subnet-0385704f22e343550" --iam-instance-profile Name=8amSSMEC2 --user-data file://ansible_install.txt --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ansible-controller},{Key=Environment,Value=Development},{Key=ProjectName,Value=CloudBinary},{Key=ProjectID,Value=20221003},{Key=EmailID,Value=admin@cloudbinary.io},{Key=MobileNo,Value=+919100073006}]'

ansible_install.txt

# Install Ansible 

#!/bin/bash

# Setup New Hostname
hostnamectl set-hostname "ansible-controller.cloudbinary.io"

# Configure New Hostname as part of /etc/hosts file 
echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts

# Update the Repository
sudo apt update

# Download, Install & Configure Ansible
sudo apt install software-properties-common -y 

sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt install ansible -y 

# Backup the Environment File
sudo cp -pvr /etc/ansible/hosts "/etc/ansible/hosts_$(date +%F_%R)"

# Create Environment Variables
echo "[web]" > /etc/ansible/hosts

echo "`aws ec2 describe-instances --instance-ids i-0f0f6b95a1298cc06 --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text`" >> /etc/ansible/hosts

# aws ec2 describe-instances --instance-ids i-0f0f6b95a1298cc06 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
# aws ec2 describe-instances --instance-ids i-0f0f6b95a1298cc06 --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text

# To Restart SSM Agent on Ubuntu 
sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

# Attach Instance profile To EC2 Instance 
# aws ec2 associate-iam-instance-profile --iam-instance-profile Name=SA-EC2-SSM --instance-id ""


AZ-1b

aws ec2 run-instances \
--image-id "ami-053b0d53c279acc90" \ 
--count 2 \
--instance-type t2.micro \
--key-name "ansible_nv" \
--security-group-ids "sg-07a189e920fd10fee" \
--subnet-id "subnet-0592ebfbf0bb99b29" \
--iam-instance-profile Name=8amSSMEC2 \
--user-data file://web-hostname.txt \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-node1},{Key=Environment,Value=Development},{Key=ProjectName,Value=CloudBinary},{Key=ProjectID,Value=20221003},{Key=EmailID,Value=admin@cloudbinary.io},{Key=MobileNo,Value=+919100073006}]'


aws ec2 run-instances --image-id "ami-053b0d53c279acc90" --count 1 --instance-type t2.micro --key-name "ansible_nv" --security-group-ids "sg-07a189e920fd10fee" --subnet-id "subnet-0592ebfbf0bb99b29" --iam-instance-profile Name=8amSSMEC2 --user-data file://web-hostname.txt --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-node1},{Key=Environment,Value=Development},{Key=ProjectName,Value=CloudBinary},{Key=ProjectID,Value=20221003},{Key=EmailID,Value=admin@cloudbinary.io},{Key=MobileNo,Value=+919100073006}]'

#!/bin/bash

# Setup New Hostname
hostnamectl set-hostname "web.cloudbinary.io"

# Configure New Hostname as part of /etc/hosts file 
echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts

# To Restart SSM Agent on Ubuntu 
# sudo systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

# Attach Instance profile To EC2 Instance 
# aws ec2 associate-iam-instance-profile --iam-instance-profile Name=SA-EC2-SSM --instance-id ""

```

# STEP-2: 

```
Generate SSH Keys part of Ansible Controller and Share with Nodes

STEP-2 : Create User i.e. automation & Add user to visudo or /etc/sudoers file:
        
$ Login to EC2 Instance of Redhat
        
$ sudo su
        
$ hostnamectl set-hostname "ansible-node1.cloudbinary.io"
        
$ echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts
        
$ adduser automation ---> use for ubuntu

$ useradd automation ---> other linux

$ passwd automation
  Redhat@123
  Redhat@123
            
$ vi /etc/sudoers
Add below content to sudoers file
  `
  %automation ALL=(ALL) NOPASSWD: ALL
  `

$ vi /etc/ssh/sshd_config
  `
  PasswordAuthentication yes
  `
- Restart SSH Service:
$ systemctl restart sshd

```

```
---
- name: Play-1 Setting Hostname 
  hosts: web  
  become: yes
  tasks:
    - name: Update the Ubuntu Repository
      apt: update_cache=yes
      ignore_errors: yes

    - name: Set Timezone 
      command: timedatectl set-timezone Asia/Kolkata
...

```

```
---
- name: Play-1 Configure NTP 
  hosts: web
  become: yes
  tasks:
    - name: Update Ubuntu Repository
      apt: update_cache=yes
      ignore_errors: yes
      
    - name: Install NTP Server
      apt: name=ntp state=present 

    - name: Enable and Start NTP Service 
      service: name=ntp state=restarted 
...

```

```
---
- name: Play-1  
  hosts: web 
  become: yes
  tasks:
    - name: Update the Ubuntu Repository
      apt: update_cache=yes
      ignore_errors: yes

    - name: Set Timezone 
      command: timedatectl set-timezone Asia/Kolkata

    - name: Install NTP Server
      apt: name=ntp state=present 

    - name: Enable and Start NTP Service 
      service: name=ntp state=restarted 

    - name: Web Server Apache2
      apt: name=apache2 state=present 

    - name: Enable & Start Apache2 Server 
      service: name=apache2 state=restarted 

    - lineinfile:
         path: /var/www/html/index.html 
         line: 'Welcome To Cloud Binary DevOps Team'
...
```


```
---
- name: Play-1 - MySQL
  hosts: web  # ---> /etc/ansible/hosts [web] publicip or hostname of the webserver
  become: yes
  tasks:
    - name: Update the Ubuntu Repository
      apt: update_cache=yes
      ignore_errors: yes

    - name: Set Timezone 
      command: timedatectl set-timezone Asia/Kolkata

    - name: Install NTP Server
      apt: name=ntp state=present 

    - name: Enable and Start NTP Service 
      service: name=ntp state=restarted 

    - name: MySQL DB Install 
      apt: name=mysql-server state=present 

    - name: Enable & Start MySQL Server 
      service: name=mysql.service state=restarted 

...
```

```
# Copy a File

- name: copy file from local host to remote host (absolute path)
  copy:
    src: /path/to/ansible/files/test_file
    dest: $HOME/test_file


# Backup a File in Remote Node:

# Coopy a File From Ansible Controller To Ansible Nodes
---
- name: Copy a File From Ansible Controller To Ansible Node-1
  hosts: app
  become: yes
  tasks:
  - name: Copy a File
    ansible.builtin.copy:
      src: /home/automation/dev.txt
      remote_src: true
      dest: /home/automation/dev.txt_20230324
      mode: '0644'
...

```


```
---
- name: Play-1 - Tomcat
  hosts: app  # ---> /etc/ansible/hosts [app] publicip or hostname of the tomcat
  become: yes
  tasks:
    - name: Update the Ubuntu Repository
      apt: update_cache=yes
      ignore_errors: yes

    - name: Set Timezone 
      command: timedatectl set-timezone Asia/Kolkata

    - name: Install NTP Server
      apt: name=ntp state=present 

    - name: Enable and Start NTP Service 
      service: name=ntp state=restarted 

    - name: Installating JDK.
      apt: name=default-jdk state=latest

    - name: Adding Group and user for Tomcat.
      shell: groupadd tomcat && useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
      
    - name: Installating curl.
      apt: name=curl state=latest

    - name: Downloading Apache Tomcat tar.
      shell: wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.75/bin/apache-tomcat-8.5.75.tar.gz    
      args:
        chdir: /tmp

    - name: Creating Apache Tomcat home directory.
      command: mkdir /opt/tomcat

    - name: Extracting Apache Tomcat.
      shell: tar -xzvf /tmp/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1

    - name: Updating permission.
      command: "{{ item }}"
      with_items:
        - chown -R tomcat:tomcat /opt/tomcat
        - chmod -R g+r /opt/tomcat/conf
        - chmod g+x /opt/tomcat/conf

    - name: Creating service for Apache tomcat.
      file:
        path: /etc/systemd/system/tomcat.service
        state: touch
        mode: u+rwx,g-rwx,o-x

    - name: Upload a tomcat.service file unto /etc/systemd/system/
      get_url:
        src: ./tomcat.service
        dest: /etc/systemd/system/tomcat.service

    - name: Deamon reload.
      command: systemctl daemon-reload

    - name: Starting Apache Tomcat service.
      service: name=tomcat state=started

...
```

```
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```


#### Ansible Tomcat Role Code:
    https://gitlab.com/kesav.kummari/ansible-role-tomcat


#### Ansible Controller is on Ubuntu and We need to Talk to Redhat/CentOS/AmazonLinux and Windows
    
    STEP-1 : Launch 2 EC2 Instances

```
- Ubuntu [Ansible Controller]

aws ec2 run-instances --image-id "ami-0557a15b87f6559cf" --count 1 --instance-type t2.micro --key-name "us_east_1_keys" --security-group-ids "sg-09e7a75b97f33d7f1" --subnet-id "subnet-00a07bb8fefdfcfec" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Ansible},{Key=Environment,Value=dev}]'

```

```
- Redhat [Node-1]

aws ec2 run-instances --image-id "ami-0c9978668f8d55984" --count 1 --instance-type t2.micro --key-name "us_east_1_keys" --security-group-ids "sg-09e7a75b97f33d7f1" --subnet-id "subnet-00a07bb8fefdfcfec" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Ansible},{Key=Environment,Value=dev}]'

```

    STEP-2 : Create User i.e. automation & Add user to visudo or /etc/sudoers file:
        
        $ Login to EC2 Instance of Redhat
        
        $ sudo su
        
        $ hostnamectl set-hostname "ansible-node1.cloudbinary.io"
        
        $ echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts
        
        $ useradd automation
        
        $ passwd automation
            Redhat@123
            Redhat@123
            
        $ vi /etc/sudoers
        Add below content to sudoers file
        `
        %automation ALL=(ALL) NOPASSWD: ALL
        `

        $ vi /etc/ssh/sshd_config

        `
        PasswordAuthentication yes
        `
        - Restart SSH Service:
            $ systemctl restart sshd

    STEP-2 : Go to Ansible Controller Machine i.e. Ubuntu 
        
        $ sudo su

        $ hostnamectl set-hostname "ansible-controller.cloudbinary.io"

        $ echo "`hostname -I | awk '{ print $1}'` `hostname`" >> /etc/hosts

        $ adduser automation
        
        $ passwd automation
            Redhat@123
            Redhat@123
            
        $ vi /etc/sudoers
        Add below content to sudoers file
        `
        %automation ALL=(ALL) NOPASSWD: ALL
        `

        $ vi /etc/ssh/sshd_config

        `
        PasswordAuthentication yes
        `
        - Restart SSH Service:
            $ systemctl restart sshd

        - Login as Automation User:
        $ su - automation  

        - Generate SSH Keys:
        $ ssh-keygen 

        $ ls -lrta /home/automation/.ssh/id_rsa 

        $ ls -lrta /home/automation/.ssh/id_rsa.pub

        - Share Public Key to Node-1 i.e. Redhat
            $ ssh-copy-id node1_privateipaddress

            Note: It will ask password for first time.

        - Validate the PasswordLess Login:
            $ ssh node1_privateipaddress

        $ ls -lrta /home/automation/.ssh/authorized_keys

    STEP-3 : Download, Install & Configure Ansible on Ubuntu[ Ansible Controller Machine ]

        ```
        # Update the Repository
        sudo apt-get update

        # Download, Install & Configure Ansible
        sudo apt-get install software-properties-common -y 

        sudo add-apt-repository --yes --update ppa:ansible/ansible

        sudo apt-get install ansible -y 

        ansible --version
        ```
    
    STEP-4 : Update Nodes Details in Ansible Contoller Machine part of inventory file i.e. /etc/ansible/hosts 

        $ sudo vi /etc/ansible/hosts

        ```
        [app]
        10.2.0.1

        ```

    STEP-5 : Validate the Connection between Ansible Controller and Nodes:

        - Ping a Node :
        $ ansible <hostname> -m ping

        $ ansible app -m ping

        - Execute Linux Commands on Remote Nodes:
        
        $ ansible <hostname> -m command -a "<command>"

        - To check OS details:
        $ ansible app -m command -a "cat /etc/os-release"

        - Check disk space on a remote host:
        $ ansible <hostname> -m shell -a "df -h"

        - Copy a file to a remote host:
        $ ansible <hostname> -m copy -a "src=<local-file> dest=<remote-file>"

        - Restart a service on a remote host:
        $ ansible <hostname> -m service -a "name=<service-name> state=restarted"


   

```
#  STEP-6 : Write Playbooks
---
- name: Create a User
  hosts: web
  become: yes
  tasks:
  - name: Add the user 'kesav'
    ansible.builtin.user:
      name: kesav
    become: yes
    become_method: sudo

...

```

```
# Ansible - Variables

# _ 
# a - z
# A - Z 
# aA-zZ 
# _aAzZ
# 0-9
# Note: Variable name can not be started with numberic i.e. 0-9 


---
- name: We are exploring unto Ansible Variables
  hosts: web
  become: yes
  vars:
      state: latest
      user: joel

  tasks:
  - name: Add the user to remote nodes 
    ansible.builtin.user:
      name: "{{ user }}"

  - name: Install Nginx WebServer 
    ansible.builtin.apt:
      name: "nginx"
      state: "{{ state }}"
...

```

```
# Register Variables

- name: Register Variable Example 
  hosts: web
  become: true 
  tasks:
  - name: find a file in a folder
    ansible.builtin.shell: "find hosts"
    args:
      chdir: "/etc/"
    register: find_hosts_output
    
  - name: Use the Above Tasks output as a variable 
    ansible.builtin.debug:
      var: find_hosts_output

- name: Create a User
  hosts: app
  become: yes
  tasks:
  - name: Add the user 'kesav'
    ansible.builtin.user:
      name: kesav

```

```
# Coopy a File From Ansible Controller To Ansible Nodes
---
- name: Copy a File From Ansible Controller To Ansible Node-1
  hosts: node-1
  become: yes
  tasks:
  - name: Copy a File 
    ansible.builtin.copy:
      src: ./devopstools.txt
      dest: /tmp/devopstools.txt
      mode: '0644'
...

```


```
# Ansible MySQL Playbook
---
- name: Install and configure MySQL
  hosts: db_servers
  become: true

  vars:
    mysql_root_password: "mysecretpassword"

  tasks:
    - name: Install MySQL server
      apt:
        name: mysql-server
        state: present

    - name: Configure MySQL root user password
      mysql_user:
        login_user: root
        login_password: ""
        user: root
        password: "{{ mysql_root_password }}"
        host: localhost

    - name: Create database and user
      mysql_db:
        login_user: root
        login_password: "{{ mysql_root_password }}"
        name: mydatabase
        state: present

    - name: Grant privileges to user
      mysql_user:
        login_user: root
        login_password: "{{ mysql_root_password }}"
        name: myuser
        password: "mypassword"
        priv: "mydatabase.*:ALL"
        host: localhost
        state: present

```
####
    In this playbook:

      - hosts specifies the target hosts where MySQL will be installed and configured.
      - become is used to elevate privileges to run commands with root privileges.
      - vars defines a variable mysql_root_password that will be used to set the root password for MySQL.
      - The tasks section includes several tasks that perform the following actions:
          - Install MySQL server using the apt module.
          - Configure the MySQL root user password using the mysql_user module.
          - Create a database named mydatabase using the mysql_db module.
          - Create a user named myuser and grant it privileges to the mydatabase database using the mysql_user module.

    You can modify this playbook to suit your specific requirements, such as changing the database and user names or specifying different privileges for the user.

```
# Ansible Apache HTTP Playbook
---
- name: Install and configure Apache HTTP server
  hosts: web_servers
  become: true

  tasks:
    - name: Install Apache HTTP server
      yum:
        name: httpd
        state: present

    - name: Start and enable Apache HTTP server
      systemd:
        name: httpd
        state: started
        enabled: true

    - name: Configure firewall for Apache HTTP server
      firewalld:
        service: http
        permanent: true
        state: enabled
        immediate: true

    - name: Copy Apache HTTP server configuration file
      template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
        owner: root
        group: root
        mode: '0644'
      notify: restart httpd

  handlers:
    - name: restart httpd
      systemd:
        name: httpd
        state: restarted

```
#### 
  In this playbook:

    - hosts specifies the target hosts where the Apache HTTP server will be installed and configured.
    
    - become is used to elevate privileges to run commands with root privileges.
  
    - The tasks section includes several tasks that perform the following actions:
        - Install the Apache HTTP server using the yum module.
        - Start and enable the Apache HTTP server using the systemd module.
        - Configure the firewall to allow traffic for the HTTP service using the firewalld module.
        - Copy the Apache HTTP server configuration file from a template using the template module. The notify keyword triggers the restart httpd handler to restart the service when the configuration file is changed.
  
    - The handlers section includes a handler that restarts the Apache HTTP server using the systemd module when triggered.

  Note that the example uses the yum package manager for installing the Apache HTTP server on a Red Hat-based system. If you're using a different package manager, you'll need to adjust the yum module to use the appropriate package manager. Additionally, the example assumes that you have a template file httpd.conf.j2 that contains the Apache HTTP server configuration. You'll need to create this file with the appropriate configuration settings for your environment.


#### Here is an example of an Ansible playbook for installing and configuring the Apache HTTP server (apache2) on a remote host:

```
# Ansible Apache2 Playbook
---
- name: Install and configure Apache2
  hosts: web_servers
  become: true

  tasks:
    - name: Install Apache2
      apt:
        name: apache2
        state: present

    - name: Start and enable Apache2
      systemd:
        name: apache2
        state: started
        enabled: true

    - name: Configure firewall for Apache2
      ufw:
        rule: allow
        name: Apache
        state: enabled

    - name: Copy Apache2 configuration file
      template:
        src: apache2.conf.j2
        dest: /etc/apache2/apache2.conf
        owner: root
        group: root
        mode: '0644'
      notify: restart apache2

  handlers:
    - name: restart apache2
      systemd:
        name: apache2
        state: restarted


```

  - In this playbook:
    - hosts specifies the target hosts where the Apache HTTP server will be installed and configured.

    - become is used to elevate privileges to run commands with root privileges.

    - The tasks section includes several tasks that perform the following actions:
      - Install the Apache2 server using the apt module.

      - Start and enable the Apache2 server using the systemd module.

      - Configure the firewall to allow traffic for the Apache2 service using the ufw module.

      - Copy the Apache2 configuration file from a template using the template module. The notify keyword triggers the restart apache2 handler to restart the service when the configuration file is changed.

    - The handlers section includes a handler that restarts the Apache2 server using the systemd module when triggered.

  - Note that the example uses the apt package manager for installing the Apache2 server on an Ubuntu-based system. If you're using a different package manager, you'll need to adjust the apt module to use the appropriate package manager. Additionally, the example assumes that you have a template file apache2.conf.j2 that contains the Apache2 configuration. You'll need to create this file with the appropriate configuration settings for your environment.


#### An Ansible playbook for setting up Jenkins might look something like this:

```
# Ansible Jenkins Playbook
---
- name: Install Jenkins
  hosts: jenkins
  become: true

  tasks:
    - name: Install Java
      apt:
        name: openjdk-8-jdk
        state: present

    - name: Add Jenkins apt key
      apt_key:
        url: https://pkg.jenkins.io/debian-stable/jenkins.io.key
        state: present

    - name: Add Jenkins apt repository
      apt_repository:
        repo: deb https://pkg.jenkins.io/debian-stable binary/
        state: present

    - name: Install Jenkins
      apt:
        name: jenkins
        state: present

    - name: Start Jenkins service
      service:
        name: jenkins
        state: started

```

#### An Ansible playbook for setting up Tomcat might look something like this:

```
# Ansible Apache Tomcat Playbook
---
- name: Install Tomcat
  hosts: tomcat
  become: true

  vars:
    tomcat_version: 9.0.61
    tomcat_install_dir: /opt/tomcat
    tomcat_service_name: tomcat

  tasks:
    - name: Install Java
      apt:
        name: openjdk-8-jdk
        state: present

    - name: Create Tomcat install directory
      file:
        path: "{{ tomcat_install_dir }}"
        state: directory
        mode: 0755
        owner: root
        group: root

    - name: Download Tomcat archive
      get_url:
        url: "https://downloads.apache.org/tomcat/tomcat-{{ tomcat_version }}/v{{ tomcat_version }}/bin/apache-tomcat-{{ tomcat_version }}.tar.gz"
        dest: /tmp/apache-tomcat-{{ tomcat_version }}.tar.gz

    - name: Extract Tomcat archive
      unarchive:
        src: /tmp/apache-tomcat-{{ tomcat_version }}.tar.gz
        dest: "{{ tomcat_install_dir }}"
        remote_src: true
        copy: false

    - name: Set Tomcat ownership
      file:
        path: "{{ tomcat_install_dir }}"
        state: directory
        mode: 0755
        owner: root
        group: root
        recurse: yes

    - name: Create Tomcat service file
      template:
        src: tomcat.service.j2
        dest: /etc/systemd/system/{{ tomcat_service_name }}.service

    - name: Start Tomcat service
      systemd:
        name: "{{ tomcat_service_name }}"
        state: started
        enabled: yes

```

#### Here's an example Ansible playbook for installing and configuring Sonarqube:

```
# Ansible Sonarqube Playbook
---
- hosts: sonarqube_server
  become: yes

  vars:
    sonarqube_version: "8.6.1.40680"

  tasks:
    - name: Install Java
      apt:
        name: openjdk-11-jdk
        state: present

    - name: Download and install Sonarqube
      get_url:
        url: "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-{{ sonarqube_version }}.zip"
        dest: "/tmp/sonarqube-{{ sonarqube_version }}.zip"
      notify: Extract Sonarqube

    - name: Create Sonarqube directory
      file:
        path: "/opt/sonarqube"
        state: directory

    - name: Extract Sonarqube
      unarchive:
        src: "/tmp/sonarqube-{{ sonarqube_version }}.zip"
        dest: "/opt/sonarqube"
        remote_src: yes
        creates: "/opt/sonarqube/sonarqube-{{ sonarqube_version }}"

    - name: Set up Sonarqube service
      systemd:
        name: sonarqube
        enabled: yes
        state: started
        daemon_reload: yes
        service_args: --Xmx512m

    - name: Set up Sonarqube reverse proxy
      template:
        src: "sonarqube.conf.j2"
        dest: "/etc/nginx/conf.d/sonarqube.conf"

    - name: Restart Nginx service
      systemd:
        name: nginx
        state: restarted

```

#### 

    In this playbook, we first install Java, then download and extract the Sonarqube archive. Next, we create a directory for Sonarqube and extract the archive into it.
    
    We then set up a systemd service for Sonarqube, configure it to start automatically and with 512MB memory, and set up a reverse proxy using Nginx. 
    
    Finally, we restart Nginx to apply the new configuration.

    Note that this playbook assumes that the target server is running Ubuntu and that Nginx is already installed. 
    
    It also assumes that you have created a Jinja2 template for the Nginx configuration file named sonarqube.conf.j2. 
    
    You'll need to replace sonarqube_server with the hostname or IP address of your target server, and update the sonarqube_version variable to match the version of Sonarqube that you want to install.

#### Here's an example Ansible playbook for installing and configuring Jfrog:

```
# Ansible Jfrog Playbook
---
- hosts: artifactory_server
  become: yes

  vars:
    artifactory_version: "7.29.10"

  tasks:
    - name: Download and install Artifactory
      get_url:
        url: "https://bintray.com/jfrog/artifactory-pro/download_file?file_path=jfrog-artifactory-pro-{{ artifactory_version }}.zip"
        dest: "/tmp/jfrog-artifactory-pro-{{ artifactory_version }}.zip"
      notify: Extract Artifactory

    - name: Create Artifactory directory
      file:
        path: "/opt/artifactory"
        state: directory

    - name: Extract Artifactory
      unarchive:
        src: "/tmp/jfrog-artifactory-pro-{{ artifactory_version }}.zip"
        dest: "/opt/artifactory"
        remote_src: yes
        creates: "/opt/artifactory/artifactory-pro-{{ artifactory_version }}"

    - name: Set up Artifactory service
      systemd:
        name: artifactory
        enabled: yes
        state: started
        daemon_reload: yes

    - name: Configure Artifactory
      template:
        src: "artifactory.config.xml.j2"
        dest: "/opt/artifactory/artifactory-pro-{{ artifactory_version }}/etc/artifactory.config.xml"

    - name: Restart Artifactory service
      systemd:
        name: artifactory
        state: restarted


```


#### Jfrog OSS

```
# Ansible Jfrog OSS Playbook
---
- hosts: jfrog_server
  become: yes

  vars:
    artifactory_version: "7.27.7"

  tasks:
    - name: Install Java
      apt:
        name: openjdk-11-jdk
        state: present

    - name: Download and install JFrog Artifactory
      get_url:
        url: "https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-{{ artifactory_version }}.zip"
        dest: "/tmp/jfrog-artifactory-oss-{{ artifactory_version }}.zip"
      notify: Extract JFrog Artifactory

    - name: Create Artifactory directory
      file:
        path: "/opt/jfrog/artifactory"
        state: directory

    - name: Extract JFrog Artifactory
      unarchive:
        src: "/tmp/jfrog-artifactory-oss-{{ artifactory_version }}.zip"
        dest: "/opt/jfrog/artifactory"
        remote_src: yes
        creates: "/opt/jfrog/artifactory/artifactory-oss-{{ artifactory_version }}"

    - name: Set up Artifactory service
      systemd:
        name: artifactory
        enabled: yes
        state: started
        daemon_reload: yes

    - name: Set up Artifactory reverse proxy
      template:
        src: "artifactory.conf.j2"
        dest: "/etc/nginx/conf.d/artifactory.conf"

    - name: Restart Nginx service
      systemd:
        name: nginx
        state: restarted

```

  - In this playbook, we first install Java, then download and extract the JFrog Artifactory archive. Next, we create a directory for Artifactory and extract the archive into it. 
  
  - We then set up a systemd service for Artifactory, configure it to start automatically, and set up a reverse proxy using Nginx. Finally, we restart Nginx to apply the new configuration.

  - Note that this playbook assumes that the target server is running Ubuntu and that Nginx is already installed. It also assumes that you have created a Jinja2 template for the Nginx configuration file named artifactory.conf.j2. 
  
  - You'll need to replace jfrog_server with the hostname or IP address of your target server, and update the artifactory_version variable to match the version of Artifactory that you want to install.
