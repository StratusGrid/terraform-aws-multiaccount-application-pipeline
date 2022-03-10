### CODEPIPELINE TERRAFORM IAM ROLE ###
resource "aws_iam_role" "codepipeline_role" {
  count = var.create ? 1 : 0
  name  = "${var.name}-codepipeline"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ServiceRoleAssumption"
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.input_tags, {})
}

data "aws_iam_policy_document" "codepipeline_workload_assume_policy" {
  dynamic "statement" {
    for_each = var.workload_accounts
    content {
      actions   = ["sts:AssumeRole"]
      effect    = "Allow"
      resources = flatten([for service in statement.value.service_map : service.trusting_account_role])
    }
  }
}

data "aws_iam_policy_document" "codepipeline_artifact_bucket_policy" {
  dynamic "statement" {
    for_each = var.workload_accounts
    content {
      #      sid = "ArtifactBucketAccess"

      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]

      resources = concat(
        distinct([for service in statement.value.service_map : "arn:aws:s3:::${service.artifact_bucket}"]),
        distinct([for service in statement.value.service_map : "arn:aws:s3:::${service.artifact_bucket}/*"])
      )
    }
  }

  statement {
    sid = "PipelineECRAccess"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"
    ]
    resources = [
      var.ecr_arn
    ]
  }

  # This is used for encrypting artifacts
  dynamic "statement" {
    for_each = var.workload_accounts
    content {
      #      sid = "ArtifactBucketKMSKeyAccess"

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]

      resources = concat(
        distinct([for service in statement.value.service_map : service.artifact_kms_key_arn])
      )
    }
  }

  statement {
    sid = "CodeDeployAccess"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]

    resources = ["*"]
  }

}

resource "aws_iam_role_policy" "codepipeline_policy" {
  count  = var.create ? 1 : 0
  name   = "${var.name}-codepipeline-policy"
  role   = join("", aws_iam_role.codepipeline_role.*.id)
  policy = data.aws_iam_policy_document.codepipeline_artifact_bucket_policy.json
}

resource "aws_iam_role_policy" "codepipeline_policy_account_assume" {
  count  = var.create ? 1 : 0
  name   = "${var.name}-codepipeline-account-assume-policy"
  role   = join("", aws_iam_role.codepipeline_role.*.id)
  policy = data.aws_iam_policy_document.codepipeline_workload_assume_policy.json
}