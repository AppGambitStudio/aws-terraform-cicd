variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking Start
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "namespace_name" {
  description = "private namespace name"
}

//Networking End

//Appserver Start
variable "ecr_fe_repository_name" {
  description = "The name of the repisitory"
}

variable "ecr_be_repository_name" {
  description = "The name of the repisitory"
}

variable "aws_cloudwatch_log_group" {
  description = "aws_cloudwatch_log_group"
}

variable "Application_name" {
  description = "Application_name"
}

variable "ecs_execution_role_name" {
  description = "ecs_execution_role_name"
}

variable "ecs_role" {
  description = "ecs_role"
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

variable "scan_on_push" {
  description = "ECR scan on push"
}

variable "fe_container_memory" {
  description = "fe container memory"
}

variable "be_container_memory" {
  description = "be container memory"
}

//Appserver End

//Databse Start

variable "global_cluster_identifier" {
  description = "global cluster identifier"
}

variable "cluster_identifier" {
  description = "cluster identifier"
}

variable "replication_source_identifier" {
  description = "replication source identifier"
}

variable "engine" {
  description = "engine"
}

variable "engine_mode" {
  description = "engine mode"
}

variable "database_name" {
  description = "database name"
}

variable "master_username" {
  description = "master username"
}

variable "master_password" {
  description = "master password"
}

variable "db_cluster_parameter_group_name" {
  description = "db cluster parameter group name"
}

variable "final_snapshot_identifier" {
  description = "final snapshot identifier"
}

variable "backup_retention_period" {
  description = "backup retention period"
}

variable "preferred_backup_window" {
  description = "preferred backup window"
}

variable "preferred_maintenance_window" {
  description = "preferred maintenance window"
}

variable "skip_final_snapshot" {
  description = "skip final snapshot"
}

variable "storage_encrypted" {
  description = "storage encrypted"
}

variable "apply_immediately" {
  description = "apply immediately"
}

variable "iam_database_authentication_enabled" {
  description = "iam database authentication enabled"
}

variable "backtrack_window" {
  description = "backtrack window"
}

variable "copy_tags_to_snapshot" {
  description = "copy tags to snapshot"
}

variable "deletion_protection" {
  description = "deletion protection"
}

variable "auto_pause" {
  description = "auto pause"
}

variable "max_capacity" {
  description = "max capacity"
}

variable "min_capacity" {
  description = "min capacity"
}

variable "seconds_until_auto_pause" {
  description = "seconds until auto pause"
}

//Databse end

//CodeCommit Start
variable "FE_Repository_Name" {
  description = "FE Repository Name..."
}

variable "FE_Repository_Branch" {
  description = "Repository Branch..."
}

variable "BE_Repository_Name" {
  description = "BE Repository Name..."
}

variable "BE_Repository_Branch" {
  description = "BE Repository Branch..."
}

//Codecommit End

//CodeBuild Start
variable "first_buildproject_name" {
  description = "First build project name..."
}

variable "second_buildproject_name" {
  description = "Second build project name..."
}
//CodeBuild End

//CodePipeline Start
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

//CodePipeline End

// CloudTrail Start
variable "cloudtrail_logs_name" {
  description = "cloudtrail logs name"
}

variable "cloudtrail_bucket_name" {
  description = "cloudtrail bucket name"
}
// CloudTrail End
