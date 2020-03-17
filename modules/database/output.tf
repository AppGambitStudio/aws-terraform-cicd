output "aws_rds_cluster_endpoint" {
  value = "${aws_rds_cluster.this.endpoint}"
}

output "aws_rds_cluster_database_name" {
  value = "${aws_rds_cluster.this.database_name}"
}

output "aws_rds_cluster_master_username" {
  value = "${aws_rds_cluster.this.master_username}"
}
