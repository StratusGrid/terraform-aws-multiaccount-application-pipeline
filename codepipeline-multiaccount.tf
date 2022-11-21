#data "aws_kms_alias" "s3" {
#  name = "alias/aws/s3"
#}

resource "aws_codepipeline" "codepipeline_application" {
  count    = var.create ? 1 : 0
  name     = "${var.name}-pipeline"
  role_arn = join("", aws_iam_role.codepipeline_role[*].arn)

  artifact_store {
    location = one(distinct(flatten([for account in var.workload_accounts : [for service in account["service_map"] : service.artifact_bucket]])))
    type     = "S3"
    encryption_key {
      id   = one(distinct(flatten([for account in var.workload_accounts : [for service in account["service_map"] : service.artifact_kms_key_arn]])))
      type = "KMS"
    }
  }
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name}-cp-terraform"
    },
  )

  stage {
    name = "Source"

    action {
      owner            = "AWS"
      name             = "ArtifactsECR"
      category         = "Source"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["ArtifactsECR"]

      configuration = {
        RepositoryName = var.ecr_name
        ImageTag       = var.ecr_tag
      }
    }

    dynamic "action" {
      for_each = flatten([for account in var.workload_accounts : [for service_map in account["service_map"] : service_map]])
      content {
        owner            = "AWS"
        name             = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
        category         = "Source"
        provider         = "S3"
        version          = "1"
        output_artifacts = ["ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"]

        configuration = {
          PollForSourceChanges = "false"
          S3Bucket             = action.value["artifact_bucket"]
          S3ObjectKey          = action.value["artifact_key"]
        }
      }
    }
  }

  stage {
    name = "Deploy_to_DEV"

    dynamic "action" {
      for_each = [for service in var.workload_accounts["dev"]["service_map"] : service]

      content {
        name            = "Deploy_${action.value["codedeploy_deployment_app_name"]}_to_DEV"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        version         = "1"
        input_artifacts = ["ArtifactsECR", "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"]
        run_order       = 1
        role_arn        = action.value["trusting_account_role"]

        configuration = {
          AppSpecTemplateArtifact        = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
          ApplicationName                = action.value["codedeploy_deployment_app_name"]
          DeploymentGroupName            = action.value["codedeploy_deployment_group_name"]
          Image1ArtifactName             = "ArtifactsECR"
          Image1ContainerName            = "IMAGE1_NAME"
          TaskDefinitionTemplateArtifact = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
          AppSpecTemplatePath            = "appspec.yaml"
          TaskDefinitionTemplatePath     = "taskdef.json"
        }
      }
    }

    action {
      category  = "Approval"
      name      = "Approve_Deployment_to_QA"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
    }
  }

  stage {
    name = "Deploy_to_QA_and_PRD"

    dynamic "action" {
      for_each = [for service in var.workload_accounts["qa"]["service_map"] : service]

      content {
        name            = "Deploy_${action.value["codedeploy_deployment_app_name"]}_to_QA"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        version         = "1"
        input_artifacts = ["ArtifactsECR", "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"]
        run_order       = 1
        role_arn        = action.value["trusting_account_role"]

        configuration = {
          AppSpecTemplateArtifact        = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
          ApplicationName                = action.value["codedeploy_deployment_app_name"]
          DeploymentGroupName            = action.value["codedeploy_deployment_group_name"]
          Image1ArtifactName             = "ArtifactsECR"
          Image1ContainerName            = "IMAGE1_NAME"
          TaskDefinitionTemplateArtifact = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
          AppSpecTemplatePath            = "appspec.yaml"
          TaskDefinitionTemplatePath     = "taskdef.json"
        }
      }
    }

    action {
      category  = "Approval"
      name      = "Approve_Deployment_to_PRD"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
    }

    dynamic "action" {
      for_each = [for service in var.workload_accounts["prd"]["service_map"] : service]

      content {
        name            = "Deploy_${action.value["codedeploy_deployment_app_name"]}_to_PRD"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        version         = "1"
        input_artifacts = ["ArtifactsECR", "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"]
        run_order       = 3
        role_arn        = action.value["trusting_account_role"]

        configuration = {
          AppSpecTemplateArtifact        = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
          ApplicationName                = action.value["codedeploy_deployment_app_name"]
          DeploymentGroupName            = action.value["codedeploy_deployment_group_name"]
          Image1ArtifactName             = "ArtifactsECR"
          Image1ContainerName            = "IMAGE1_NAME"
          TaskDefinitionTemplateArtifact = "ArtifactsS3-${action.value["codedeploy_deployment_app_name"]}"
          AppSpecTemplatePath            = "appspec.yaml"
          TaskDefinitionTemplatePath     = "taskdef.json"
        }
      }
    }

    action {
      category  = "Approval"
      name      = "Production_Deployment_Acceptance"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 4
    }
  }
}