variable "region" {
  description = "AWS region..."
}

variable "environment" {
  description = "environment"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "first_buildproject_name" {
  description = "First build project name..."
}

variable "second_buildproject_name" {
  description = "Second build project name..."
}

variable "ecr_fe_repository_url" {
  description = "ecr fe repository url..."
}

variable "ecr_be_repository_url" {
  description = "ecr be repository url..."
}

variable "fe_repository_name" {
  description = "ecr fe repository name..."
}

variable "be_repository_name" {
  description = "ecr be repository name..."
}

variable "fe_container_memory" {
  description = "fe_container_memory"
}

variable "be_container_memory" {
  description = "be_container_memory"
}

variable "subnets_id_1" {
  description = "subnets ids"
}

variable "subnets_id_2" {
  description = "subnets ids"
}

variable "public_subnet_id_1" {
  description = "public subnets ids"
}

variable "public_subnet_id_2" {
  description = "public subnets ids"
}

variable "security_groups_ids" {
  type        = list
  description = "The SGs to use"
}

variable "ecs_security_group_id" {
  description = "ecs_security_group_id"
}

variable "ecs_fe_task_defination_family" {
  description = "ecs_fe_task_defination_family"
}

variable "ecs_be_task_defination_family" {
  description = "ecs_be_task_defination_family"
}
