variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "region" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "cluster_name" {
  default = ""
}

variable "instance_class" {
  default = "db.r5.8xlarge"
}

variable "database_username" {
  default = ""
}

variable "database_password" {
  default = ""
}

variable "database_name" {
  default = ""
}

variable "cluster_size" {
  default = 3
}

variable "subnet_group_name" {
  default = ""
}

variable "vpc_security_group_id" {
  default = [""]
}

