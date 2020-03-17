resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.random_id_prefix}-codepipeline-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_access_block" {
  bucket = "${aws_s3_bucket.codepipeline_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

/* role for Amazon CodePipeline */
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.random_id_prefix}-codepipeline-role"
  assume_role_policy = "${file("${path.module}/policies/code-pipeline-role.json")}"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.random_id_prefix}-codepipeline-policy"
  policy = "${file("${path.module}/policies/codepipeline-service-role-policy.json")}"
  role   = "${aws_iam_role.codepipeline_role.id}"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.random_id_prefix}-${var.fe_pipeline_name}-fe"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["sourceout"]

      configuration = {
        RepositoryName = "${var.Codecommit_fe_RepositoryName}"
        BranchName     = "${var.fe_repo_BranchName}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "${var.first_buildproject_name}"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["sourceout"]
      output_artifacts = ["buildout1"]
      version          = "1"

      configuration = {
        ProjectName = "${var.first_buildproject_name}"
      }
    }
  }

  stage {
    name = "Deployment"

    action {
      name     = "${var.first_buildproject_name}"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      input_artifacts = ["buildout1"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.fe_service_name}"
        FileName    = "feimagedefinitions.json"
      }
    }
  }
}

resource "aws_codepipeline" "codepipeline2" {
  name     = "${var.random_id_prefix}-${var.be_pipeline_name}-be"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "${var.Codecommit_be_RepositoryName}"
        BranchName     = "${var.be_repo_BranchName}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "${var.second_buildproject_name}"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["buildout2"]
      version          = "1"

      configuration = {
        ProjectName = "${var.second_buildproject_name}"
      }
    }
  }

  stage {
    name = "Deployment"

    action {
      name            = "${var.second_buildproject_name}"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["buildout2"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.be_service_name}"
        FileName    = "beimagedefinitions.json"
      }
    }
  }
}
