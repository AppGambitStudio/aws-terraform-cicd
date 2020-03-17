output "first_build_project_name" {
  value = "${aws_codebuild_project.codebuild_project_1.name}"
}

output "second_build_project_name" {
  value = "${aws_codebuild_project.codebuild_project_2.name}"
}

