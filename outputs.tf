output "workload_accounts" {
  value       = var.workload_accounts
  description = "Map of workload accounts, assumable IAM roles in them, and their order of execution in CodePipeline."
}