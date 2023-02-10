
###------------
### S3
###------------

output "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  value       = module.s3_bucket.bucket_arn
}
output "s3_bucket_domain_name" {
  description = "FQDN of S3 bucket"
  value       = module.s3_bucket.bucket_domain_name
}
output "s3_bucket_id" {
  description = "S3 Bucket Name (aka ID)"
  value       = module.s3_bucket.bucket_id
}
output "s3_bucket_region" {
  description = "S3 Bucket region"
  value       = module.s3_bucket.bucket_region
}

###------------
### SES
###------------

output "ses_dkim_tokens" {
  description = "A list of DKIM Tokens which, when added to the DNS Domain as CNAME records, allows for receivers to verify that emails were indeed authorized by the domain owner."
  value       = module.ses.ses_dkim_tokens
}
output "ses_domain_identity_arn" {
  description = "The ARN of the SES domain identity"
  value       = module.ses.ses_domain_identity_arn
}
output "ses_domain_identity_verification_token" {
  description = "A code which when added to the domain as a TXT record will signal to SES that the owner of the domain has authorised SES to act on their behalf. The domain identity will be in state 'verification pending' until this is done."
  value       = module.ses.ses_domain_identity_verification_token
}
output "ses_group_name" {
  description = "The IAM group name"
  value       = module.ses.ses_group_name
}
output "ses_user_arn" {
  description = "SMTP user ARN"
  value       = module.ses.user_arn
}
output "ses_user_name" {
  description = "SMTP user name"
  value       = module.ses.user_name
}
output "ses_rules_recipients" {
  description = "SES receipt rules"
  value       = { for k, rule in aws_ses_receipt_rule.s3 : k => rule.recipients }
}
output "ses_rules_s3_action" {
  description = "SES receipt rules"
  value       = { for k, rule in aws_ses_receipt_rule.s3 : k => rule.s3_action[*] }
}
