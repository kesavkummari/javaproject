variable "ami" {
  default = "ami-0a0e5d9c7acc336f1" //Ubuntu 22.04
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "tf-windows"
}

variable "subnet_id_1a" {
  default = "subnet-0385704f22e343550"
}

# variable "subnet_id_1b" {
#   default = "subnet-0592ebfbf0bb99b29"
# }

variable "iam_instance_profile" {
  default = "8amSSMEC2"
}
variable "sonar_instance_type" {
  default = "t2.medium"
}