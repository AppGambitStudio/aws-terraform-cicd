output "fe_repository_url" {
  value = "${aws_ecr_repository.fe_app.repository_url}"
}

output "fe_repository_name" {
  value = "${aws_ecr_repository.fe_app.name}"
}

output "be_repository_url" {
  value = "${aws_ecr_repository.be_app.repository_url}"
}

output "be_repository_name" {
  value = "${aws_ecr_repository.be_app.name}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.cluster.name}"
}

output "fe_service_name" {
  value = "${aws_ecs_service.fe.name}"
}

output "be_service_name" {
  value = "${aws_ecs_service.be.name}"
}

output "security_group_id" {
  value = "${aws_security_group.ecs_service.id}"
}