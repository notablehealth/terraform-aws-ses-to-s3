# terraform-aws-module-template

[![Releases](https://img.shields.io/github/v/release/NotableHealth/terraform-aws-ses-to-s3)](https://github.com/NotableHealth/terraform-aws-ses-to-s3/releases/tag/latest)

[Terraform Module Registry](https://registry.terraform.io/modules/NotableHealth/ses-to-s3/aws)

Terraform module for managing AWS SES and S3 to receive email and put in S3 bucket. This does not currently do any of the DNS set.

## Features

- S3 bucket
  - Bucket policy
  - Lifecycle for cleanup
- SES domain
  - Rule to send mail to S3

## Usage

```
module "ses_to_s3" {
    source "../.."
    # Recommend pinning every module to a specific version
    # version = "x.x.x"

    name_s3     = var.name_s3
    namespace   = var.namespace
    stage       = var.stage
    s3_prefix   = var.s3_prefix
    ses_domain  = var.ses_domain
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.53.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label_s3"></a> [label\_s3](#module\_label\_s3) | cloudposse/label/null | 0.25.0 |
| <a name="module_label_ses"></a> [label\_ses](#module\_label\_ses) | cloudposse/label/null | 0.25.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | cloudposse/s3-bucket/aws | 3.0.0 |
| <a name="module_ses"></a> [ses](#module\_ses) | cloudposse/ses/aws | 0.22.3 |

## Resources

| Name | Type |
|------|------|
| [aws_ses_active_receipt_rule_set.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_active_receipt_rule_set) | resource |
| [aws_ses_receipt_rule.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_receipt_rule) | resource |
| [aws_ses_receipt_rule_set.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_receipt_rule_set) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_s3"></a> [name\_s3](#input\_name\_s3) | S3 bucket name (functional name ONLY) | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of resources | `string` | n/a | yes |
| <a name="input_s3_expiration"></a> [s3\_expiration](#input\_s3\_expiration) | Expire current S3 objects in days | `number` | `14` | no |
| <a name="input_s3_expiration_noncurrent_days"></a> [s3\_expiration\_noncurrent\_days](#input\_s3\_expiration\_noncurrent\_days) | Expire noncurrent S3 objects in days | `number` | `1` | no |
| <a name="input_s3_expiration_noncurrent_versions"></a> [s3\_expiration\_noncurrent\_versions](#input\_s3\_expiration\_noncurrent\_versions) | Expire noncurrent S3 objects versions (Versions to keep) | `number` | `1` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | S3 prefix for incoming mail | `string` | n/a | yes |
| <a name="input_ses_domain"></a> [ses\_domain](#input\_ses\_domain) | SES domain | `string` | n/a | yes |
| <a name="input_ses_recipents"></a> [ses\_recipents](#input\_ses\_recipents) | value | `list(string)` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Deployment stage of resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | S3 Bucket ARN |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | FQDN of S3 bucket |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | S3 Bucket Name (aka ID) |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | S3 Bucket region |
| <a name="output_ses_dkim_tokens"></a> [ses\_dkim\_tokens](#output\_ses\_dkim\_tokens) | A list of DKIM Tokens which, when added to the DNS Domain as CNAME records, allows for receivers to verify that emails were indeed authorized by the domain owner. |
| <a name="output_ses_domain_identity_arn"></a> [ses\_domain\_identity\_arn](#output\_ses\_domain\_identity\_arn) | The ARN of the SES domain identity |
| <a name="output_ses_domain_identity_verification_token"></a> [ses\_domain\_identity\_verification\_token](#output\_ses\_domain\_identity\_verification\_token) | A code which when added to the domain as a TXT record will signal to SES that the owner of the domain has authorised SES to act on their behalf. The domain identity will be in state 'verification pending' until this is done. |
| <a name="output_ses_group_name"></a> [ses\_group\_name](#output\_ses\_group\_name) | The IAM group name |
| <a name="output_ses_user_arn"></a> [ses\_user\_arn](#output\_ses\_user\_arn) | SMTP user ARN |
| <a name="output_ses_user_name"></a> [ses\_user\_name](#output\_ses\_user\_name) | SMTP user name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
