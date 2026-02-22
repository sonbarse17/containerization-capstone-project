resource "aws_ecr_repository" "repo" {
  name                 = "${var.project_name}-${var.environment}-${var.repository_name}"
  force_delete         = var.force_delete
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.repository_name}"
    Environment = var.environment
  }
}
