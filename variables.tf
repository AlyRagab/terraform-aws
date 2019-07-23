variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

variable "aws_region" {
  default = "us-east-1"
}
variable "public_key_path" {
  default   = ""
}
variable "cidr_subnet" {
  default = "10.10.0.0/24"
}
variable "cidr_vpc" {
  default = "10.10.0.0/16"
}
variable "instance_type" {
  default  = "t2.micro"
}
variable "aws-ami" {
  default  = "ami-003f19e0e687de1cd"
}
variable "availability_zone" {
  default  = "us-east-1a"
}
variable "volume-size" {
  default  = 10
}
