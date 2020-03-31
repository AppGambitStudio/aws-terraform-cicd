resource "random_id" "random_id_prefix" {
  byte_length = 2
}
/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

provider "aws" {
  region  = "${var.region}"
}

module "networking" {
  source               = "./modules/networking"
  region               = "${var.region}"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${local.production_availability_zones}"
  namespace_name       = "${var.namespace_name}"
}

module "storage" {
  source                = "./modules/storage"
  environment           = "${var.environment}"
  uploads_bucket_prefix = "${random_id.random_id_prefix.hex}-assets"
}

module "codecommit" {
  source = "./modules/codecommit"

  region               = "${var.region}"
  random_id_prefix     = "${random_id.random_id_prefix.hex}"
  FE_Repository_Name   = "${var.FE_Repository_Name}"
  FE_Repository_Branch = "${var.FE_Repository_Branch}"
  BE_Repository_Name   = "${var.BE_Repository_Name}"
  BE_Repository_Branch = "${var.BE_Repository_Branch}"
}

module "codebuild" {
  source = "./modules/codebuild"

  region                        = "${var.region}"
  environment                   = "${var.environment}"
  random_id_prefix              = "${random_id.random_id_prefix.hex}"
  first_buildproject_name       = "${var.first_buildproject_name}"
  second_buildproject_name      = "${var.second_buildproject_name}"
  ecr_fe_repository_url         = "${module.appserver.fe_repository_url}"
  ecr_be_repository_url         = "${module.appserver.be_repository_url}"
  fe_repository_name            = "${module.appserver.fe_repository_name}"
  be_repository_name            = "${module.appserver.be_repository_name}"
  fe_container_memory           = "${var.fe_container_memory}"
  be_container_memory           = "${var.be_container_memory}"
  security_groups_ids           = "${module.networking.security_groups_ids}"
  ecs_security_group_id         = "${module.appserver.security_group_id}"
  subnets_id_1                  = "${module.networking.private_subnet_1}"
  public_subnet_id_1            = "${module.networking.public_subnet_1}"
  subnets_id_2                  = "${module.networking.private_subnet_2}"
  public_subnet_id_2            = "${module.networking.public_subnet_2}"
  ecs_fe_task_defination_family = "${module.appserver.ecs_fe_task_defination_family}"
  ecs_be_task_defination_family = "${module.appserver.ecs_be_task_defination_family}"
}

module "codedeploy" {
  source = "./modules/codedeploy"

  region                     = "${var.region}"
  random_id_prefix           = "${random_id.random_id_prefix.hex}"
  environment                = "${var.environment}"
  ecs_execution_role_arn     = "${module.appserver.ecs_execution_role_arn}"
  ecs_cluster_name           = "${module.appserver.cluster_name}"
  ecs_service_name           = "${module.appserver.fe_service_name}"
  be_service_name            = "${module.appserver.be_service_name}"
  aws_alb_target_group_arn_1 = "${module.appserver.aws_alb_target_group_arn_1}"
  aws_alb_target_group_arn_2 = "${module.appserver.aws_alb_target_group_arn_2}"
  alb_target_group_be_arn_1  = "${module.appserver.alb_target_group_be_arn_1}"
  alb_target_group_be_arn_2  = "${module.appserver.alb_target_group_be_arn_2}"
  aws_alb_listener_1_arn     = "${module.appserver.aws_alb_listener_1_arn}"
  aws_alb_listener_2_arn     = "${module.appserver.aws_alb_listener_2_arn}"
  be_alb_listener_1_arn      = "${module.appserver.be_alb_listener_1_arn}"
  be_alb_listener_2_arn      = "${module.appserver.be_alb_listener_2_arn}"
}

module "codepipeline" {
  source = "./modules/codepipeline"

  region                       = "${var.region}"
  environment                  = "${var.environment}"
  random_id_prefix             = "${random_id.random_id_prefix.hex}"
  fe_pipeline_name             = "${var.fe_pipeline_name}"
  fe_repo_BranchName           = "${var.fe_repo_BranchName}"
  be_pipeline_name             = "${var.be_pipeline_name}"
  be_repo_BranchName           = "${var.be_repo_BranchName}"
  first_buildproject_name      = "${module.codebuild.first_build_project_name}"
  second_buildproject_name     = "${module.codebuild.second_build_project_name}"
  Codecommit_fe_RepositoryName = "${module.codecommit.codecommit_fe_repo}"
  Codecommit_be_RepositoryName = "${module.codecommit.codecommit_be_repo}"
  cluster_name                 = "${module.appserver.cluster_name}"
  fe_service_name              = "${module.appserver.fe_service_name}"
  be_service_name              = "${module.appserver.be_service_name}"
}

module "appserver" {
  source                         = "./modules/appserver"
  environment                    = "${var.environment}"
  region                         = "${var.region}"
  random_id_prefix               = "${random_id.random_id_prefix.hex}"
  ecr_fe_repository_name         = "${var.ecr_fe_repository_name}"
  ecr_be_repository_name         = "${var.ecr_be_repository_name}"
  aws_cloudwatch_log_group       = "${var.aws_cloudwatch_log_group}"
  Application_name               = "${var.Application_name}"
  ecs_role                       = "${var.ecs_role}"
  ecs_execution_role_name        = "${var.ecs_execution_role_name}"
  ecs_service_role_policy_name   = "${var.ecs_service_role_policy_name}"
  ecs_execution_role_policy_name = "${var.ecs_execution_role_policy_name}"
  ecs_autoscale_role_policy_name = "${var.ecs_autoscale_role_policy_name}"
  vpc_id                         = "${module.networking.vpc_id}"
  security_groups_ids            = "${module.networking.security_groups_ids}"
  subnets_ids                    = ["${module.networking.private_subnets_id}"]
  public_subnet_ids              = ["${module.networking.public_subnets_id}"]
  DB_URL                         = "${module.database.aws_rds_cluster_endpoint}"
  DB_NAME                        = "${module.database.aws_rds_cluster_database_name}"
  DB_USERNAME                    = "${module.database.aws_rds_cluster_master_username}"
  DB_PASSWORD                    = "${var.master_password}"
  scan_on_push                   = "${var.scan_on_push}"
  fe_container_memory            = "${var.fe_container_memory}"
  be_container_memory            = "${var.be_container_memory}"

}

module "database" {
  source = "./modules/database"

  environment                         = "${var.environment}"
  global_cluster_identifier           = "${var.global_cluster_identifier}"
  cluster_identifier                  = "${var.cluster_identifier}"
  replication_source_identifier       = "${var.replication_source_identifier}"
  source_region                       = "${var.region}"
  engine                              = "${var.engine}"
  engine_mode                         = "${var.engine_mode}"
  database_name                       = "${var.database_name}"
  master_username                     = "${var.master_username}"
  master_password                     = "${var.master_password}"
  vpc_security_group_ids              = "${module.networking.default_sg_id}"
  db_cluster_parameter_group_name     = "${var.db_cluster_parameter_group_name}"
  subnet_ids                          = ["${module.networking.private_subnets_id}"]
  final_snapshot_identifier           = "${var.environment}-snapshot-${random_id.random_id_prefix.dec}"
  backup_retention_period             = "${var.backup_retention_period}"
  preferred_backup_window             = "${var.preferred_backup_window}"
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  storage_encrypted                   = "${var.storage_encrypted}"
  apply_immediately                   = "${var.apply_immediately}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"
  backtrack_window                    = "${var.backtrack_window}"
  copy_tags_to_snapshot               = "${var.copy_tags_to_snapshot}"
  deletion_protection                 = "${var.deletion_protection}"
  auto_pause                          = "${var.auto_pause}"
  max_capacity                        = "${var.max_capacity}"
  min_capacity                        = "${var.min_capacity}"
  seconds_until_auto_pause            = "${var.seconds_until_auto_pause}"
  app_server_sg                       = "${module.appserver.security_group_id}"
  vpc_id                              = "${module.networking.vpc_id}"
}

module "notificationsalarm" {
  source = "./modules/notificationsalarm"

  region           = "${var.region}"
  environment      = "${var.environment}"
  random_id_prefix = "${random_id.random_id_prefix.hex}"
}

module "cloudtrail" {
  source = "./modules/cloudtrail"

  region                 = "${var.region}"
  environment            = "${var.environment}"
  random_id_prefix       = "${random_id.random_id_prefix.hex}"
  cloudtrail_logs_name   = "${random_id.random_id_prefix.hex}_${var.cloudtrail_logs_name}"
  cloudtrail_bucket_name = "${random_id.random_id_prefix.hex}-${var.cloudtrail_bucket_name}"

}
