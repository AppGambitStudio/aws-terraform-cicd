/* role for Amazon CodeBuild */
resource "aws_iam_role" "codebuild_role" {
  name               = "${var.random_id_prefix}-codebuild-role"
  assume_role_policy = "${file("${path.module}/policies/codebuild-role.json")}"
}

resource "aws_iam_role_policy" "codebuild_ec2container_policy" {
  name   = "${var.random_id_prefix}-codebuild-ec2container-policy"
  policy = "${file("${path.module}/policies/codepipeline-ec2container-role-policy.json")}"
  role   = "${aws_iam_role.codebuild_role.id}"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.random_id_prefix}-codebuild-policy"
  policy = "${file("${path.module}/policies/codebuild-role-policy.json")}"
  role   = "${aws_iam_role.codebuild_role.id}"
}

data "template_file" "buildspec_fe" {
  template = "${file("${path.module}/buildspec/buildspec-fe.yml")}"

  vars = {
    region                = "${var.region}"
    ecr_fe_repository_url = "${var.ecr_fe_repository_url}"
    fe_repository_name    = "${var.fe_repository_name}"
  }
}

data "template_file" "buildspec_be" {
  template = "${file("${path.module}/buildspec/buildspec-be.yml")}"

  vars = {
    region                = "${var.region}"
    ecr_be_repository_url = "${var.ecr_be_repository_url}"
    be_repository_name    = "${var.be_repository_name}"
  }
}

resource "aws_codebuild_project" "codebuild_project_1" {
  name          = "${var.random_id_prefix}-${var.first_buildproject_name}-codebuild"
  description   = "Build Project.."
  build_timeout = "50"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec_fe.rendered}"
  }
}

resource "aws_codebuild_project" "codebuild_project_2" {
  name          = "${var.random_id_prefix}-${var.second_buildproject_name}-codebuild"
  description   = "Build Project.."
  build_timeout = "50"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec_be.rendered}"

  }
}
