resource "aws_ecr_repository" "petclinic" {
  name                 = "${var.stack}-petclinic"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.stack}-petclinic"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "petclinic" {
  repository = aws_ecr_repository.petclinic.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 30
      }
      action = {
        type = "expire"
      }
    }]
  })
} 