variable "region" {
  description = "AWS Region"
}

variable "environment" {
  description = "The environment"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "ecs_cluster_name" {
  description = "ecs cluster name"
}

variable "ecs_service_name" {
  description = "ecs service name"
}

variable "be_service_name" {
  description = "be_service_name"
}

variable "aws_alb_target_group_arn_1" {
  description = "aws alb target group arn"
}

variable "aws_alb_target_group_arn_2" {
  description = "aws alb target group arn"
}

variable "alb_target_group_be_arn_1" {
  description = "alb_target_group_be_arn"
}

variable "alb_target_group_be_arn_2" {
  description = "alb_target_group_be_arn"
}


variable "aws_alb_listener_1_arn" {
  description = "aws lb listener arn 1"
}

variable "aws_alb_listener_2_arn" {
  description = "aws lb listener arn 2"
}

variable "be_alb_listener_1_arn" {
  description = "aws lb listener arn 1"
}

variable "be_alb_listener_2_arn" {
  description = "aws lb listener arn 2"
}

variable "ecs_execution_role_arn" {
  description = "ecs_execution_role_arn"
}
