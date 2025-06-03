# ---------------------------------------------------------------------------------------------------------------------
# APPRUNNER IAM Role
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "apprunner_service_role" {
  name = "${var.apprunner_service_role}AppRunnerECRAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.apprunner_service_role}AppRunnerECRAccessRole"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "apprunner_service_role_policy" {
  name = "${var.apprunner_service_role}AppRunnerECRAccessPolicy"
  role = aws_iam_role.apprunner_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "apprunner_instance_role" {
  name = "${var.apprunner_service_role}AppRunnerInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.apprunner_service_role}AppRunnerInstanceRole"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "apprunner_instance_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter${data.aws_ssm_parameter.dbpassword.name}"]
  }
}

resource "aws_iam_role_policy" "apprunner_instance_role_policy" {
  name   = "${var.apprunner_service_role}AppRunnerInstancePolicy"
  role   = aws_iam_role.apprunner_instance_role.id
  policy = data.aws_iam_policy_document.apprunner_instance_role_policy.json
}