
variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}
variable "ses_rules" {
  description = "SES receipt rules"
  type = map(object({
    base_prefix = optional(string)
    prefix      = string
    recipients  = list(string)
  }))
}
variable "ses_rule_set_name" {
  description = "SES Rule set name and S3 prefix"
  type        = string
}
