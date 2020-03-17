region      = "us-east-2"
environment = "production"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
namespace_name       = "apps.demo.internal"

/*ERC*/
ecr_fe_repository_name = "<<< ECR Repo name for BE >>>" //like `fe/prod`
ecr_be_repository_name = "<<< ECR Repo name for FE >>>" // like be/prod
scan_on_push           = true                           // true / false

/*ECS*/
aws_cloudwatch_log_group       = "<<< ECS log group name >>>"   // like `/ecs/applog`
Application_name               = "<<< ECS application name >>>" //like `demoServer`
ecs_execution_role_name        = "ecs_task_execution_role"      //Name of ecs execution role
ecs_role                       = "ecs_role"                     //Name of ecs role
ecs_service_role_policy_name   = "ecs_service_role_policy"      //name of ecs service role policy
ecs_execution_role_policy_name = "ecs_execution_role_policy"    //Name of ecs execution role policy
ecs_autoscale_role_policy_name = "ecs_autoscale_role_policy"    //Name of ecs autoscale role policy name
fe_container_memory            = 512                            //size of your ECS service Container
be_container_memory            = 512                            //size of your ECS service Container

/*RDS Databse*/
global_cluster_identifier           = "rds-db-demo"       // Name of your RDS DB cluster
cluster_identifier                  = "default1"          //Name of your RDS cluster identifier
replication_source_identifier       = "source_identifier" //replication source identifier
engine                              = "aurora"            //Angine name like aurora, mysql etc
engine_mode                         = "serverless"        # serverless or provisioned
database_name                       = "defaultdb"         //Database name
master_username                     = "admin"             //Master user name
master_password                     = "admin123"          //Master Password
db_cluster_parameter_group_name     = "cluster_parameter" //DB parameter group name
final_snapshot_identifier           = "finalsnapshot"     //Snapshot name
backup_retention_period             = "7"
preferred_backup_window             = "02:00-03:00"
preferred_maintenance_window        = "sun:05:00-sun:06:00"
skip_final_snapshot                 = false //Default true
storage_encrypted                   = true  //Default false
apply_immediately                   = true  //Default false
iam_database_authentication_enabled = false //Default true
backtrack_window                    = 0
copy_tags_to_snapshot               = false
deletion_protection                 = true //Default false
auto_pause                          = true
max_capacity                        = 2 // DB max capacity
min_capacity                        = 1 // DB min capacity
seconds_until_auto_pause            = 300

/*module CodeCommit*/
FE_Repository_Name   = "fe_repo"
FE_Repository_Branch = "master"
BE_Repository_Name   = "be_repo"
BE_Repository_Branch = "master"

/*Code Build*/
first_buildproject_name  = "fe-project"
second_buildproject_name = "be-project"

/*Code Pipeline*/
fe_pipeline_name   = "tf-fe-pipeline"
fe_repo_BranchName = "master"
be_pipeline_name   = "tf-be-pipeline"
be_repo_BranchName = "master"

/*CloudTrail*/
cloudtrail_logs_name   = "cloudtrail_logs"
cloudtrail_bucket_name = "cloudtrail-log-bucket"
