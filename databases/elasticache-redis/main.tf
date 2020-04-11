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
    key    = "terraform/redis/terraform.tfstate"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 1
  parameter_group_name = "redis5"
  engine_version       = "5.0.6"
  port                 = 6379
  subnet_group_name    = "redis5"
  security_group_ids   = ["sg-045e372ce76219158"]

}

resource "aws_elasticache_replication_group" "redis-group" {
  automatic_failover_enabled    = true
  availability_zones            = ["me-south-1a" , "me-south-1b", "me-south-1c"]
  replication_group_id          = "replication-group-1"
  replication_group_description = "replication group for redis "
  node_type                     = "cache.t3.medium"
  number_cache_clusters         = 3
  parameter_group_name          = "redis5"
  port                          = 6379
}

resource "aws_elasticache_cluster" "replica" {
  cluster_id           = "cluster-redis"
  replication_group_id = "${aws_elasticache_replication_group.redis-group.id}"
}

