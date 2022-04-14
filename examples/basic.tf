region = "us-east-1"

name_prefix = "myservice"

vpc_name = "cicd-vpc"

data "aws_vpc" "cicd_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_s3_bucket" "cicd_artifacts" {
  bucket = "cicd-artifacts-bucket"
}

data "aws_ecr_repository" "service" { # This is defined at the account level; will match the name shown in Nexus
  name = "service"
}

locals {
  cicd_account_number = 123456789012
  workload_account_number = 234567890123
  dev_ecs_application_service_map = {
    catsvc_codepipeline_variables = {
      "artifact_appspec_file_name" = "appspec.yaml"
      "artifact_bucket" = "artifacts-cicd"
      "artifact_key" = "deployment/ecs/dev/artifacts.zip"
      "artifact_kms_key_arn" = "arn:aws:kms:us-east-1:${local.cicd_account_number}:key/abcdefgh-5678-ijkl-9012-10a9bd61a94a"
      "artifact_taskdef_file_name" = "taskdef.json"
      "aws_account_number" = "${local.workload_account_number}"
      "codedeploy_deployment_app_arn" = "arn:aws:codedeploy:us-east-1:${local.workload_account_number}:application:cat-catalog-dev"
      "codedeploy_deployment_app_name" = "cat-catalog-dev"
      "codedeploy_deployment_group_arn" = "arn:aws:codedeploy:us-east-1:${local.workload_account_number}:deploymentgroup:cat-catalog-dev/cat-catalog-dev"
      "codedeploy_deployment_group_name" = "cat-catalog-dev"
      "trusting_account_role" = "arn:aws:iam::${local.workload_account_number}:role/cat-catalog-dev-cicd"
    }
    catsvc_rmq_codepipeline_variables = {
      "artifact_appspec_file_name" = "appspec.yaml"
      "artifact_bucket" = "tp-cicd-artifacts-cicd"
      "artifact_key" = "deployment/ecs/dev/catsvc-rmq-artifacts.zip"
      "artifact_kms_key_arn" = "arn:aws:kms:us-east-1:${local.cicd_account_number}:key/abcdefgh-5678-ijkl-9012-10a9bd61a94a"
      "artifact_taskdef_file_name" = "taskdef.json"
      "aws_account_number" = "${local.workload_account_number}"
      "codedeploy_deployment_app_arn" = "arn:aws:codedeploy:us-east-1:${local.workload_account_number}:application:cat-catalog-rmq-dev"
      "codedeploy_deployment_app_name" = "cat-catalog-rmq-dev"
      "codedeploy_deployment_group_arn" = "arn:aws:codedeploy:us-east-1:${local.workload_account_number}:deploymentgroup:cat-catalog-rmq-dev/cat-catalog-rmq-dev"
      "codedeploy_deployment_group_name" = "cat-catalog-rmq-dev"
      "trusting_account_role" = "arn:aws:iam::${local.workload_account_number}:role/cat-catalog-rmq-dev-cicd"
    }
  }
}

module "fargate_application_deployment_pipeline" {
  source = "./modules/terraform-aws-multiaccount-application-pipeline"

  create = true

  name               = "${var.name_prefix}-app-deploy"
  log_retention_days = 7
  vpc_id             = data.aws_vpc.cicd_vpc.id

  cp_resource_bucket_arn      = data.aws_s3_bucket.cicd_artifacts.arn
  cp_resource_bucket_name     = data.aws_s3_bucket.cicd_artifacts.bucket
  cp_resource_bucket_key_name = "service/master.zip"

  ecr_name = data.aws_ecr_repository.service.name
  ecr_arn  = data.aws_ecr_repository.service.arn
  ecr_tag  = "latest"

  ecs_service_name                 = "service"
  codedeploy_deployment_group_name = "service_deployment"

  workload_accounts = {
    dev = {
      account_id      = "000000000000"
      manual_approval = false
      order           = 1
      service_map     = var.dev_ecs_application_service_map
    }
    qa = {
      account_id      = "111111111111"
      manual_approval = true
      order           = 2
      service_map     = var.qa_ecs_application_service_map
    }
    prd = {
      account_id      = "222222222222"
      manual_approval = true
      order           = 2
      service_map     = var.prd_ecs_application_service_map
    }
  }
}
