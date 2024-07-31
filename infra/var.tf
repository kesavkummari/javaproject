variable "ami" {
  default = "ami-053b0d53c279acc90"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "nv_aws"
}

variable "subnet_id_1a" {
  default = "subnet-0385704f22e343550"
}

variable "subnet_id_1b" {
  default = "subnet-0592ebfbf0bb99b29"
}

variable "iam_instance_profile" {
  default = "8amSSMEC2"
}