
###------------
### Naming (label) information
###------------
variable "name_s3" {
  description = "S3 bucket name (functional name ONLY)"
  type        = string
}

variable "namespace" {
  description = "Namespace of resources"
  type        = string
}
variable "stage" {
  description = "Deployment stage of resources"
  type        = string
}

###------------
### S3 Lifecycle
###------------
variable "s3_expiration" {
  description = "Expire current S3 objects in days"
  type        = number
  default     = 14
}
variable "s3_expiration_noncurrent_days" {
  description = "Expire noncurrent S3 objects in days"
  type        = number
  default     = 1
}
variable "s3_expiration_noncurrent_versions" {
  description = "Expire noncurrent S3 objects versions (Versions to keep)"
  type        = number
  default     = 1
}

###------------
### SES
###------------
variable "ses_active_receipt_rule_set" {
  description = "SES active receipt rule set"
  type        = string
}
variable "ses_domain" {
  description = "SES domain"
  type        = string
}

variable "ses_rule_sets" {
  description = "SES receipt rule sets"
  type = map(object({
    rules = map(object({
      base_prefix = optional(string)
      prefix      = string
      recipients  = list(string)
    }))
  }))
  #default = {
  #  "test" = {
  #    rules = {
  #      "tester" = {
  #        prefix     = "tester"
  #        recipients = ["tester@mailbox.abc.com"]
  #      }
  #    }
  #  }
  #}
}
