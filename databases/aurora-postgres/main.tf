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
    key    = "terraform/postgres/terraform.tfstate"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_rds_cluster" "postgres" {
  #count                   = "${length(data.aws_availability_zones.available.names)}"
  cluster_identifier      = "${var.cluster_name}"
  engine                  = "aurora-postgresql"
  engine_version          = "11.6"
  availability_zones      = ["me-south-1a" , "me-south-1b", "me-south-1c"]
  database_name           = "${var.database_name}"
  master_username         = "${var.database_username}"
  master_password         = "${var.database_password}"
  backup_retention_period = 7
  preferred_backup_window = "09:30-09:00"
  skip_final_snapshot     = "true"
  apply_immediately       = "true"
  vpc_security_group_ids  = "${var.vpc_security_group_id}"
  db_subnet_group_name    = "${var.subnet_group_name}"
  tags = {
    Name = "test-aurora"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              =  3
  identifier         = "${var.cluster_name}-${count.index}"
  cluster_identifier = "${aws_rds_cluster.postgres.cluster_identifier}"
  instance_class     = "${var.instance_class}"
  engine             = "aurora-postgresql"
  #allocated_storage  = 50
  tags = {
    Name = "test-aurora"
  }
}


#output "Cluster_Endpoint" {
#  value = "${aws_rds_cluster.postgres[count.index]-endpoint}"
#}

output "Cluster_Instance_Endpoints" {
  value = "${aws_rds_cluster_instance.cluster_instances.*.endpoint}"
}

#output "Reader_Endpoint" {
#  value = "${aws_rds_cluster.postgres[count.index]-endpoint}"
#}

