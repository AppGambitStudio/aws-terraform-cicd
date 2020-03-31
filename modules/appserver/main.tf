locals {
  target_groups = ["primary", "secondary"]
}

/*====
ECR repository to store our Docker images
======*/
resource "aws_ecr_repository" "fe_app" {
  name = "${var.ecr_fe_repository_name}"

  image_scanning_configuration {
    scan_on_push = "${var.scan_on_push}"
  }

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_ecr_lifecycle_policy" "fe_app_policy" {
  repository = "${aws_ecr_repository.fe_app.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "be_app" {
  name = "${var.ecr_be_repository_name}"

  image_scanning_configuration {
    scan_on_push = "${var.scan_on_push}"
  }

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_ecr_lifecycle_policy" "be_app_policy" {
  repository = "${aws_ecr_repository.be_app.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

/*====
Cloudwatch Log Group
======*/
resource "aws_cloudwatch_log_group" "fe_log" {
  name              = "${var.random_id_prefix}-${var.aws_cloudwatch_log_group}-fe"
  retention_in_days = 30

  tags = {
    Environment = "${var.environment}"
    Application = "${var.Application_name}-fe"
  }
}

resource "aws_cloudwatch_log_stream" "fe_log_stream" {
  name           = "${var.random_id_prefix}-${var.environment}-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.fe_log.name}"
}

resource "aws_cloudwatch_log_group" "be_log" {
  name              = "${var.random_id_prefix}-${var.aws_cloudwatch_log_group}-be"
  retention_in_days = 30

  tags = {
    Environment = "${var.environment}"
    Application = "${var.Application_name}-be"
  }
}

resource "aws_cloudwatch_log_stream" "be_log_stream" {
  name           = "${var.random_id_prefix}-${var.environment}-jobs-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.be_log.name}"
}

//ECS
/*
* IAM service role
*/
data "aws_iam_policy_document" "ecs_service_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "${var.random_id_prefix}-${var.ecs_role}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_role.json}"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress"
    ]
  }
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.random_id_prefix}-${var.ecs_service_role_policy_name}"
  policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
  role   = "${aws_iam_role.ecs_role.id}"
}

/* role that the Amazon ECS container agent and the Docker daemon can assume */
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.random_id_prefix}-${var.ecs_execution_role_name}"
  assume_role_policy = "${file("${path.module}/policies/ecs-task-execution-role.json")}"
}
resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.random_id_prefix}-${var.ecs_execution_role_policy_name}"
  policy = "${file("${path.module}/policies/ecs-execution-role-policy.json")}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
}

/*====
ECS task definitions
======*/

/* the task definition for the web service */
data "template_file" "fe_task" {
  template = "${file("${path.module}/tasks/fe_task_definition.json")}"

  vars = {
    region              = "${var.region}"
    image               = "${aws_ecr_repository.fe_app.repository_url}"
    log_group           = "${aws_cloudwatch_log_group.fe_log.name}"
    BE_SERVER           = "${aws_alb.alb_application_be.dns_name}"
    fe_container_memory = "${var.fe_container_memory}"
  }
}

resource "aws_ecs_task_definition" "fe" {
  family                   = "${var.environment}-fe"
  container_definitions    = "${data.template_file.fe_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"

  tags = {
    Environment = "${var.environment}"
  }
}

data "template_file" "be_task" {
  template = "${file("${path.module}/tasks/be_task_definition.json")}"

  vars = {
    region              = "${var.region}"
    image               = "${aws_ecr_repository.be_app.repository_url}"
    log_group           = "${aws_cloudwatch_log_group.be_log.name}"
    DB_URL              = "${var.DB_URL}"
    DB_NAME             = "${var.DB_NAME}"
    DB_USERNAME         = "${var.DB_USERNAME}"
    DB_PASSWORD         = "${var.DB_PASSWORD}"
    be_container_memory = "${var.be_container_memory}"
  }
}

resource "aws_ecs_task_definition" "be" {
  family                   = "${var.environment}-be"
  container_definitions    = "${data.template_file.be_task.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"

  tags = {
    Environment = "${var.environment}"
  }
}

/*====
ECS service
======*/

/* Security Group for ECS */
resource "aws_security_group" "ecs_service" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.random_id_prefix}-${var.environment}-ecs-service-sg"
  description = "Allow egress from container"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.random_id_prefix}-${var.environment}-ecs-service-sg"
    Environment = "${var.environment}"
  }
}

/*====
Auto Scaling for ECS
======*/

resource "aws_iam_role" "ecs_autoscale_role" {
  name               = "${var.random_id_prefix}-${var.ecs_autoscale_role_policy_name}"
  assume_role_policy = "${file("${path.module}/policies/ecs-autoscale-role.json")}"
}

resource "aws_iam_role_policy" "ecs_autoscale_role_policy" {
  name   = "${var.random_id_prefix}-${var.ecs_autoscale_role_policy_name}"
  policy = "${file("${path.module}/policies/ecs-autoscale-role-policy.json")}"
  role   = "${aws_iam_role.ecs_autoscale_role.id}"
}

resource "aws_appautoscaling_target" "target_fe" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.fe.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = 1
  max_capacity       = 4
}

resource "aws_appautoscaling_policy" "up_fe" {
  name               = "${var.random_id_prefix}-${var.environment}_scale_up_fe"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.fe.name}"
  scalable_dimension = "ecs:service:DesiredCount"


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target_fe]
}

resource "aws_appautoscaling_policy" "down_fe" {
  name               = "${var.random_id_prefix}-${var.environment}_scale_down_fe"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.fe.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target_fe]
}

resource "aws_appautoscaling_target" "target_be" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.be.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = 1
  max_capacity       = 4
}

resource "aws_appautoscaling_policy" "up_be" {
  name               = "${var.random_id_prefix}-${var.environment}_scale_up_be"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.be.name}"
  scalable_dimension = "ecs:service:DesiredCount"


  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target_be]
}

resource "aws_appautoscaling_policy" "down_be" {
  name               = "${var.random_id_prefix}-${var.environment}_scale_down_be"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.be.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target_be]
}

/* metric used for auto scale */
resource "aws_cloudwatch_metric_alarm" "service_cpu_high_fe" {
  alarm_name          = "${var.random_id_prefix}-${var.environment}_application_web_cpu_utilization_high_fe"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "85"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
    ServiceName = "${aws_ecs_service.fe.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up_fe.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down_fe.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high_be" {
  alarm_name          = "${var.random_id_prefix}-${var.environment}_application_web_cpu_utilization_high_be"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "85"

  dimensions = {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
    ServiceName = "${aws_ecs_service.be.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up_be.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down_be.arn}"]
}

/*====
App Load Balancer
======*/
resource "random_id" "target_group_sufix" {
  byte_length = 2
}

resource "aws_alb_target_group" "alb_target_group" {
  count = "${length(local.target_groups)}"
  name  = "${var.environment}-tg-${element(local.target_groups, count.index)}-fe"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Environment = "${var.environment}"
  }

  depends_on = [aws_alb.alb_application]
}

/* security group for ALB */
resource "aws_security_group" "web_inbound_sg" {
  name        = "${var.random_id_prefix}-${var.environment}-web-inbound-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.random_id_prefix}-${var.environment}-web-inbound-sg"
  }
}

resource "aws_alb" "alb_application" {
  name            = "${var.environment}-alb-application"
  subnets         = flatten(["${var.public_subnet_ids}"])
  security_groups = flatten(["${var.security_groups_ids}", "${aws_security_group.web_inbound_sg.id}"])

  tags = {
    Name        = "${var.environment}-alb-application"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "application" {
  load_balancer_arn = "${aws_alb.alb_application.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.alb_target_group]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.0.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "application1" {
  load_balancer_arn = "${aws_alb.alb_application.arn}"
  port              = "8000"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.alb_target_group]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.0.arn}"
    type             = "forward"
  }
}

//Loadbalancer
resource "aws_alb_target_group" "alb_target_group_be" {
  count = "${length(local.target_groups)}"
  name  = "${var.environment}-tg-${element(local.target_groups, count.index)}-be"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Environment = "${var.environment}"
  }

  depends_on = [aws_alb.alb_application_be]
}

/* security group for ALB */
resource "aws_security_group" "web_inbound_sg_be" {
  name        = "${var.random_id_prefix}-${var.environment}-web-inbound-sg-be"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.random_id_prefix}-${var.environment}-web-inbound-sg-be"
  }
}

resource "aws_alb" "alb_application_be" {
  name            = "${var.environment}-alb-application-be-t"
  internal        = true
  subnets         = flatten(["${var.subnets_ids}"])
  security_groups = flatten(["${var.security_groups_ids}", "${aws_security_group.web_inbound_sg_be.id}"])

  tags = {
    Name        = "${var.environment}-alb-application"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "application_be" {
  load_balancer_arn = "${aws_alb.alb_application_be.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.alb_target_group_be]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group_be.0.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "application_be1" {
  load_balancer_arn = "${aws_alb.alb_application_be.arn}"
  port              = "8080"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.alb_target_group_be]

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group_be.0.arn}"
    type             = "forward"
  }
}

/*====
ECS cluster
======*/
resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Environment = "${var.environment}"
  }
}

/* Simply specify the family to find the latest ACTIVE revision in that family */
data "aws_ecs_task_definition" "fe" {
  task_definition = "${aws_ecs_task_definition.fe.family}"
  depends_on      = [aws_ecs_task_definition.fe]
}

resource "aws_ecs_service" "fe" {
  name            = "${var.environment}-fe"
  task_definition = "${aws_ecs_task_definition.fe.family}:${max("${aws_ecs_task_definition.fe.revision}", "${data.aws_ecs_task_definition.fe.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.cluster.id}"

  network_configuration {
    security_groups = flatten(["${var.security_groups_ids}", "${aws_security_group.ecs_service.id}"])
    subnets         = flatten(["${var.subnets_ids}"])
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.0.arn}"
    container_name   = "fe"
    container_port   = "8000"
  }

  tags = {
    Environment = "${var.environment}"
  }
  depends_on = [aws_alb_listener.application, aws_iam_role_policy.ecs_service_role_policy, aws_alb_target_group.alb_target_group]
}

data "aws_ecs_task_definition" "be" {
  task_definition = "${aws_ecs_task_definition.be.family}"
  depends_on      = [aws_ecs_task_definition.be]
}

resource "aws_ecs_service" "be" {
  name            = "${var.environment}-be"
  task_definition = "${aws_ecs_task_definition.be.family}:${max("${aws_ecs_task_definition.be.revision}", "${data.aws_ecs_task_definition.be.revision}")}"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.cluster.id}"

  network_configuration {
    security_groups = flatten(["${var.security_groups_ids}", "${aws_security_group.ecs_service.id}"])
    subnets         = flatten(["${var.subnets_ids}"])
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_be.0.arn}"
    container_name   = "be"
    container_port   = "8080"
  }

  tags = {
    Environment = "${var.environment}"
  }
  depends_on = [aws_alb_listener.application, aws_iam_role_policy.ecs_service_role_policy, aws_alb_target_group.alb_target_group_be]
}
