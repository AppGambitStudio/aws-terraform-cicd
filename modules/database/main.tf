
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = flatten(["${var.subnet_ids}"])

  tags = {
    Name = "DB subnet group"
  }
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.environment}-db-access-sg"
  description = "Allow access to DocumentDB"

  tags = {
    Name        = "${var.environment}-db-access-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "rdsdb_sg" {
  name        = "${var.environment}-rdsdb-sg"
  description = "${var.environment} RDS mysql aurora serverless Security Group"
  vpc_id      = "${var.vpc_id}"
  tags = {
    Name        = "${var.environment}-rdsdb-sg"
    Environment = "${var.environment}"
  }

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  //allow traffic for TCP 27017
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.db_access_sg.id}"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.app_server_sg}"]
  }

  // outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "rds-cluster-pg"
  family      = "aurora5.6"
  description = "RDS default cluster parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier                  = "${var.cluster_identifier}"
  source_region                       = "${var.source_region}"
  engine                              = "${var.engine}"
  engine_mode                         = "${var.engine_mode}"
  database_name                       = "${var.database_name}"
  master_username                     = "${var.master_username}"
  master_password                     = "${var.master_password}"
  final_snapshot_identifier           = "${var.final_snapshot_identifier}"
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  backup_retention_period             = "${var.backup_retention_period}"
  preferred_backup_window             = "${var.preferred_backup_window}"
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  db_subnet_group_name                = "${aws_db_subnet_group.db_subnet_group.name}"
  vpc_security_group_ids              = ["${aws_security_group.rdsdb_sg.id}"]
  storage_encrypted                   = "${var.storage_encrypted}"
  apply_immediately                   = "${var.apply_immediately}"
  db_cluster_parameter_group_name     = "${aws_rds_cluster_parameter_group.default.id}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"
  backtrack_window                    = "${var.backtrack_window}"
  copy_tags_to_snapshot               = "${var.copy_tags_to_snapshot}"
  # deletion_protection                 = "${var.deletion_protection}"

  scaling_configuration {
    auto_pause               = "${var.auto_pause}"
    max_capacity             = "${var.max_capacity}"
    min_capacity             = "${var.min_capacity}"
    seconds_until_auto_pause = "${var.seconds_until_auto_pause}"
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = {
    Name = "aws RDS Cluster"
  }
}



