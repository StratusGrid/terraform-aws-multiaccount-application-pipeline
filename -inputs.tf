variable "codedeploy_deployment_group_name" {
  description = "Name of this service's deployment group."
  type        = string
}

variable "cp_resource_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket where the source artifacts will be kept."
}

variable "cp_resource_bucket_name" {
  type        = string
  description = "Name of the S3 bucket where the source artifacts will be kept."
}

variable "cp_resource_bucket_key_name" {
  type        = string
  description = "Prefix and key of the source artifact file. For instance, `source/master.zip`."
}

variable "create" {
  description = "Conditionally create resources. Affects nearly all resources."
  type        = bool
  default     = true
}

variable "ecr_arn" {
  description = "ARN of ECR where application container image is kept."
  type        = string
}

variable "ecr_name" {
  description = "Name of ECR where application container image is kept."
  type        = string
}

variable "ecr_tag" {
  description = "Tag of application container image to deploy."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS Service being deployed"
  type        = string
}

variable "input_tags" {
  description = "Map of tags to apply to all taggable resources."
  type        = map(string)
  default = {
    Provisioner = "Terraform"
  }
}

variable "name" {
  type        = string
  default     = "codepipline-module"
  description = "Name to prepend to all resource names within module."
}

variable "log_retention_days" {
  description = "Number of days to retain logs for. Configured on Log Group which all log streams are put under."
  type        = number
}


variable "workload_accounts" {
  description = "Map of workload accounts, assumable IAM roles in them, and their order of execution in CodePipeline."
  type = map(object(
    {
      account_id      = string
      manual_approval = bool
      order           = number
      service_map     = map(map(string))
    }
  ))
}

variable "vpc_id" {
  description = "VPC which all resources will be put into"
  type        = string
}

#variable "cd_accounts_map" {
#  type        = map(object(
#    {
#      account_id      = string
#      iam_role        = string
#      manual_approval = bool
#      order           = number
#    }
#  ))
#  description = "Map of environments, IAM assumption roles, AWS accounts to create pipeline stages for."
#}