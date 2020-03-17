//Server Repository
resource "aws_codecommit_repository" "codecommit_fe_repo" {
  repository_name = "${var.FE_Repository_Name}"
  description     = "This is the CodeCommit Repository"
  default_branch  = "${var.FE_Repository_Branch}"
}

resource "aws_codecommit_repository" "codecommit_be_repo" {
  repository_name = "${var.BE_Repository_Name}"
  description     = "This is the CodeCommit Repository"
  default_branch  = "${var.BE_Repository_Branch}"
}

data "template_file" "policy_codecommit" {
  template = "${file("${path.module}/policies/codecommit-policy.json")}"

  vars = {
    random_id_prefix = "$${var.random_id_prefix}"
    RESOURCES        = "${aws_codecommit_repository.codecommit_fe_repo.arn}"
  }
}

resource "aws_iam_policy" "codecommit_policy" {
  name   = "${var.random_id_prefix}-codecommit-restrict-policy"
  policy = "${data.template_file.policy_codecommit.rendered}"
}
