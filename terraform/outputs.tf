output "application_url" {
  value = "http://${aws_instance.app.public_ip}"
}
output "ec2_instance_id" {
  value = aws_instance.app.id
}
output "ecr_repository_name" {
  value = aws_ecr_repository.app.name
}
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
