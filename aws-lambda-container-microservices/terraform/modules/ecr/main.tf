resource "aws_ecr_repository" "repo" {
  name = "${var.project_name}-repo"
}

output "repo_url" {
  value = aws_ecr_repository.repo.repository_url
}
