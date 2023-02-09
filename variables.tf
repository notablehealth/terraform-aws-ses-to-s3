
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
### S3
###------------
variable "s3_prefix" {
  description = "S3 prefix for incoming mail"
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
variable "ses_domain" {
  description = "SES domain"
  type        = string
}
variable "ses_recipents" {
  description = "value"
  type        = list(string)
}
