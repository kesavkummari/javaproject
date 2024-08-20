# Versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Providers
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}


# Resource
resource "aws_instance" "k8s_cp" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id_1a
  vpc_security_group_ids = ["sg-0a3fe1b73a2b3e0d2"]
  iam_instance_profile   = var.iam_instance_profile
  #user_data              = file("/Users/ck/repos/iac-terraform/iac/web.sh")
  user_data = <<-EOF
  #!/bin/bash
  sudo hostnamectl set-hostname "k8s-cp.cloudbinary.io"
  echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts
  sudo apt-get update
  sudo apt-get install git wget unzip curl tree -y
  sudo apt-get -y install git binutils

  # Load the following kernel modules on all the nodes
  # Disable swap & add kernel settings
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

  # Load the following kernel modules on all the nodes
  sudo echo "overlay" > /etc/modules-load.d/containerd.conf 
  sudo echo "br_netfilter" >> /etc/modules-load.d/containerd.conf 
  
  sudo modprobe overlay
  sudo modprobe br_netfilter

  # Set the following Kernel parameters for Kubernetes, run beneath tee command
  sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf 
  sudo echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/kubernetes.conf 
  sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/kubernetes.conf 

  # Reload the above changes, run
  sudo sysctl --system

  # Install containerd run time
  sudo apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


  # Enable docker repository
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  # Now, run following apt command to install containerd
  sudo apt-get update
  sudo apt-get install -y containerd.io

  # Configure containerd so that it starts using systemd as cgroup.
  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

  # Restart and enable containerd service
  sudo systemctl restart containerd
  sudo systemctl enable containerd

  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  # Install Kubernetes components Kubectl, kubeadm & kubelet
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl

  export KUBECONFIG=/etc/kubernetes/admin.conf
  # Initialize Kubernetes cluster with Kubeadm command
  su - ubuntu
  id
  pwd
  cd
  sudo kubeadm init --control-plane-endpoint=k8s-cp.cloudbinary.io >> /home/ubuntu/k8s-cluster.output
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # Install Calico Pod Network Add-on
  # Run following kubectl command to install Calico network plugin from the master node,
  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

  EOF

  tags = {
    Name        = "k8s_cp"
    Environment = "Dev"
    ProjectName = "Cloud Binary"
    ProjectID   = "2024"
    CreatedBy   = "IaC Terraform"
  }
}

resource "aws_instance" "k8s_node" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id_1a
  vpc_security_group_ids = ["sg-0a3fe1b73a2b3e0d2"]
  iam_instance_profile   = var.iam_instance_profile
  #user_data              = file("/Users/ck/repos/iac-terraform/iac/web.sh")
  user_data = <<-EOF
  #!/bin/bash
  sudo hostnamectl set-hostname "k8s-cm.cloudbinary.io"
  echo "`hostname -I | awk '{ print $1 }'` `hostname`" >> /etc/hosts
  sudo apt-get update
  sudo apt-get install git wget unzip curl tree -y
  sudo apt-get -y install git binutils

  # Load the following kernel modules on all the nodes
  # Disable swap & add kernel settings
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

  # Load the following kernel modules on all the nodes
  sudo echo "overlay" > /etc/modules-load.d/containerd.conf 
  sudo echo "br_netfilter" >> /etc/modules-load.d/containerd.conf 
  
  sudo modprobe overlay
  sudo modprobe br_netfilter

  # Set the following Kernel parameters for Kubernetes, run beneath tee command
  sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf 
  sudo echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/kubernetes.conf 
  sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/kubernetes.conf 

  # Reload the above changes, run
  sudo sysctl --system

  # Install containerd run time
  sudo apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates


  # Enable docker repository
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  # Now, run following apt command to install containerd
  sudo apt-get update
  sudo apt-get install -y containerd.io

  # Configure containerd so that it starts using systemd as cgroup.
  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

  # Restart and enable containerd service
  sudo systemctl restart containerd
  sudo systemctl enable containerd

  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  # Install Kubernetes components Kubectl, kubeadm & kubelet
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl

  EOF
  tags = {
    Name        = "k8s_node"
    Environment = "Dev"
    ProjectName = "Cloud Binary"
    ProjectID   = "2024"
    CreatedBy   = "IaC Terraform"
  }
}

# Outputs
output "ami" {
  value = aws_instance.k8s_cp.ami
}
output "public_ip" {
  value = aws_instance.k8s_cp.public_ip
}
output "private_ip" {
  value = aws_instance.k8s_cp.private_ip
}

output "k8s_node_public_ip" {
  value = aws_instance.k8s_node.public_ip
}
output "k8s_node_private_ip" {
  value = aws_instance.k8s_node.private_ip
}