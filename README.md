<!-- BEGIN_TF_DOCS -->
# terraform-aws-multiaccount-application-pipeline
GitHub: [StratusGrid/terraform-aws-multiaccount-application-pipeline](https://github.com/StratusGrid/terraform-aws-multiaccount-application-pipeline)

This terraform module creates a multi-account Fargate application deployment pipeline.

## Example
```hcl

```
## StratusGrid Standards we assume
- All resource names and name tags shall use `_` and not `-`s
- The old naming standard for common files such as inputs, outputs, providers, etc was to prefix them with a `-`, this is no longer true as it's not POSIX compliant. Our pre-commit hooks will fail with this old standard.
- StratusGrid generally follows the TerraForm standards outlined [here](https://www.terraform-best-practices.com/naming)
## Repo Knowledge
Repository for Module vmimport
## Documentation
This repo is self documenting via Terraform Docs, please see the note at the bottom.
### `LICENSE`
This is the standard Apache 2.0 License as defined [here](https://stratusgrid.atlassian.net/wiki/spaces/TK/pages/2121728017/StratusGrid+Terraform+Module+Requirements).
### `outputs.tf`
The StratusGrid standard for Terraform Outputs.
### `README.md`
It's this file! I'm always updated via TF Docs!
### `tags.tf`
The StratusGrid standard for provider/module level tagging. This file contains logic to always merge the repo URL.
### `variables.tf`
All variables related to this repo for all facets.
One day this should be broken up into each file, maybe maybe not.
### `versions.tf`
This file contains the required providers and their versions. Providers need to be specified otherwise provider overrides can not be done.
## Documentation of Misc Config Files
This section is supposed to outline what the misc configuration files do and what is there purpose
### `.config/.terraform-docs.yml`
This file auto generates your `README.md` file.
### `.github/workflows/pre-commit.yml`
This file contains the instructions for Github workflows, in specific this file run pre-commit and will allow the PR to pass or fail. This is a safety check and extras for if pre-commit isn't run locally.
### `examples/*`
The files in here are used by `.config/terraform-docs.yml` for generating the `README.md`. All files must end in `.tfnot` so Terraform validate doesn't trip on them since they're purely example files.
### `.gitignore`
This is your gitignore, and contains a slew of default standards.
---
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |
## Resources

| Name | Type |
|------|------|
| [aws_codepipeline.codepipeline_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codepipeline_policy_account_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Conditionally create resources. Affects nearly all resources. | `bool` | `true` | no |
| <a name="input_ecr_arn"></a> [ecr\_arn](#input\_ecr\_arn) | ARN of ECR where application container image is kept. | `string` | n/a | yes |
| <a name="input_ecr_name"></a> [ecr\_name](#input\_ecr\_name) | Name of ECR where application container image is kept. | `string` | n/a | yes |
| <a name="input_ecr_tag"></a> [ecr\_tag](#input\_ecr\_tag) | Tag of application container image to deploy. | `string` | n/a | yes |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to all taggable resources. | `map(string)` | <pre>{<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name to prepend to all resource names within module. | `string` | `"codepipline-module"` | no |
| <a name="input_workload_accounts"></a> [workload\_accounts](#input\_workload\_accounts) | Map of workload accounts, assumable IAM roles in them, and their order of execution in CodePipeline. | <pre>map(object(<br>    {<br>      account_id      = string<br>      manual_approval = bool<br>      order           = number<br>      service_map     = map(map(string))<br>    }<br>  ))</pre> | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workload_accounts"></a> [workload\_accounts](#output\_workload\_accounts) | Map of workload accounts, assumable IAM roles in them, and their order of execution in CodePipeline. |
---
Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->