resource "aws_sns_topic" "terraform-infra-notification" {
  name = "${var.random_id_prefix}-terraform-infra-notification"
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn = "${aws_sns_topic.terraform-infra-notification.arn}"

  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "sns:Subscribe",
      "sns:SetTopicAttributes",
      "sns:RemovePermission",
      "sns:Receive",
      "sns:Publish",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:DeleteTopic",
      "sns:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.terraform-infra-notification.arn}",
    ]
    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "sns:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      "${aws_sns_topic.terraform-infra-notification.arn}",
    ]

    sid = "__default_statement_ID_1"
  }
}

resource "aws_cloudwatch_event_rule" "ecs-running-event" {
  name        = "${var.random_id_prefix}-ecs-running-event"
  description = "Capture ECS event"

  event_pattern = <<PATTERN
{
  "detail-type": [
    "ECS Task State Change"
  ],
  "source": [
    "aws.ecs"
  ],
  "detail": {
    "lastStatus": [
      "RUNNING"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_notifications-running" {
  rule      = "${aws_cloudwatch_event_rule.ecs-running-event.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.terraform-infra-notification.id}"
}

resource "aws_cloudwatch_event_rule" "ecs-stop-event" {
  name        = "${var.random_id_prefix}-ecs-stop-event"
  description = "Capture ECS event"

  event_pattern = <<PATTERN
{
  "detail-type": [
    "ECS Task State Change"
  ],
  "source": [
    "aws.ecs"
  ],
  "detail": {
    "lastStatus": [
      "STOPPED"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_notifications-stop" {
  rule      = "${aws_cloudwatch_event_rule.ecs-stop-event.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.terraform-infra-notification.id}"
}

resource "aws_cloudwatch_event_rule" "ecr-push-rule" {
  name        = "ecr-push-rule"
  description = "Capture ECR push"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecr"
  ],
  "detail-type": [
    "ECR Image Action"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_notifications-ecr-push" {
  rule      = "${aws_cloudwatch_event_rule.ecr-push-rule.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.terraform-infra-notification.id}"
}
