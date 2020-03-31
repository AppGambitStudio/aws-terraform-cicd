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

output "aws_alb_target_group_arn_1" {
  value = "${aws_alb_target_group.alb_target_group.0.name}"
}

output "aws_alb_target_group_arn_2" {
  value = "${aws_alb_target_group.alb_target_group.1.name}"
}

output "alb_target_group_be_arn_1" {
  value = "${aws_alb_target_group.alb_target_group_be.0.name}"
}

output "alb_target_group_be_arn_2" {
  value = "${aws_alb_target_group.alb_target_group_be.1.name}"
}

output "aws_alb_listener_1_arn" {
  value = "${aws_alb_listener.application.arn}"
}

output "aws_alb_listener_2_arn" {
  value = "${aws_alb_listener.application.arn}"
}

output "be_alb_listener_1_arn" {
  value = "${aws_alb_listener.application_be.arn}"
}

output "be_alb_listener_2_arn" {
  value = "${aws_alb_listener.application_be1.arn}"
}

output "ecs_execution_role_arn" {
  value = "${aws_iam_role.ecs_execution_role.arn}"
}

output "ecs_fe_task_defination_family" {
  value = "${aws_ecs_task_definition.fe.family}"
}

output "ecs_be_task_defination_family" {
  value = "${aws_ecs_task_definition.be.family}"
}
