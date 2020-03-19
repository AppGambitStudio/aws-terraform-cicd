variable "region" {
  description = "AWS Region"
}

variable "environment" {
  description = "The environment"
}

variable "random_id_prefix" {
  description = "random id prefix"
}

variable "ecr_fe_repository_name" {
  description = "The name of the repisitory"
}

variable "ecr_be_repository_name" {
  description = "The name of the repisitory"
}

variable "aws_cloudwatch_log_group" {
  description = "aws cloudwatch log group"
}

variable "Application_name" {
  description = "Application name"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "security_groups_ids" {
  type        = list
  description = "The SGs to use"
}

variable "subnets_ids" {
  description = "subnets ids"
}

variable "public_subnet_ids" {
  type        = list
  description = "The public subnets to use"
}

variable "ecs_execution_role_name" {
  description = "ecs execution role name"
}

variable "ecs_role" {
  description = "ecs role"
}

variable "ecs_service_role_policy_name" {
  description = "ecs service role policy name"
}

variable "ecs_execution_role_policy_name" {
  description = "ecs execution role policy name"
}

variable "ecs_autoscale_role_policy_name" {
  description = "ecs autoscale role policy name"
}

variable "DB_URL" {
  description = "Database connection string"
}

variable "DB_NAME" {
  description = "Database name"
}

variable "DB_USERNAME" {
  description = "Database user name"
}

variable "DB_PASSWORD" {
  description = "Database Password"
}

variable "scan_on_push" {
  description = "ECR scan on push"
}

variable "fe_container_memory" {
  description = "fe container memory"
}

variable "be_container_memory" {
  description = "be container memory"
}
