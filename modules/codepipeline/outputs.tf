output "codepipeline_fe" {
  value = "${aws_codepipeline.codepipeline.arn}"
}

output "codepipeline_be" {
  value = "${aws_codepipeline.codepipeline2.arn}"
}
