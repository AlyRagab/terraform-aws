provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# S3 remote terraform state:
terraform {
  backend "s3" {
    bucket = "terraform-state"
    region = "me-south-1"
    key    = "terraform/mainvpc/terraform.tfstate"
  }
}

# Defining the AZ in this region:
data "aws_availability_zones" "available" {
}

# AWS_VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_vpc}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet_Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public_Subnet 1
resource "aws_subnet" "public-subnet" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.${10+count.index}.0/24"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Private_Subnet 1
resource "aws_subnet" "private_subnet" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.${20+count.index}.0/24"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# Route Table for public subnets:
resource "aws_route_table" "publci-route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.project_name}-public-route"
  }
}

# Join Subnet to Route_Table:
resource "aws_route_table_association" "public-route" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.publci-route.id}"
}

# Elastic IP for NAT Gateway:
resource "aws_eip" "nat-eip" {
  vpc = true

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# Nat Gateway :
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id     = "${element(aws_subnet.private_subnet.*.id, 1)}"
  depends_on    = ["aws_internet_gateway.igw"]

  tags = {
    Name = "${var.project_name}-nat_gateway"
  }
}

# Route Table for Private Subnet:
resource "aws_route_table" "private-route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  tags = {
    Name = "${var.project_name}-private-route"
  }
}

# Join Subnet to Private Table:
resource "aws_route_table_association" "private-table" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-route.id}"
}


