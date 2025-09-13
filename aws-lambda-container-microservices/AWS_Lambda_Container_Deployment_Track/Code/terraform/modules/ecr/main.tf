resource "aws_ecr_repository" "repo" {
  name = "appointment-service-repo"
}

output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}
