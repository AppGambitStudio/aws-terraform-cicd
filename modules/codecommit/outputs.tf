output "codecommit_fe_repo" {
  value = "${aws_codecommit_repository.codecommit_fe_repo.repository_name}"
}

output "codecommit_be_repo" {
  value = "${aws_codecommit_repository.codecommit_be_repo.repository_name}"
}
