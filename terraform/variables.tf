variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "project_name" {
  type    = string
  default = "github-actions-ec2-cicd"
}
variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}
variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}
variable "github_branch" {
  type    = string
  default = "main"
}
