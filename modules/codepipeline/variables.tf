variable "region" {
  description = "AWS region..."
}

variable "environment" {
  description = "environment"
}

variable "random_id_prefix" {
  description = "random prefix"
}

variable "fe_pipeline_name" {
  description = "Code pipeline project name..."
}

variable "fe_repo_BranchName" {
  description = "FE Repository Branch Name..."
}

variable "be_pipeline_name" {
  description = "Code pipeline project name..."
}

variable "be_repo_BranchName" {
  description = "BE Repository Branch Name..."
}

variable "first_buildproject_name" {
  description = "First build project name..."
}

variable "second_buildproject_name" {
  description = "Second build project name..."
}

variable "Codecommit_fe_RepositoryName" {
  description = "fe Codecommit Repository Name..."
}

variable "Codecommit_be_RepositoryName" {
  description = "be Codecommit Repository Name..."
}

variable "cluster_name" {
  description = "cluster name"
}

variable "fe_service_name" {
  description = "fe name server"
}

variable "be_service_name" {
  description = "be name job"
}


