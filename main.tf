
# Reference
#  https://aws.amazon.com/premiumsupport/knowledge-center/ses-receive-inbound-emails/
#  https://tech-universe.net/posts/aws/how-to-receive-mail-in-amazon-ses-and-save-it-in-s3/
#  https://cuddly-octo-palm-tree.com/posts/2021-10-24-aws-email-forwarding-tf/
#  https://github.com/alemuro/terraform-aws-ses-email-forwarding

# https://github.com/cloudposse/terraform-null-label
module "label_s3" {
  #checkov:skip=CKV_TF_1
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  stage       = var.stage
  name        = var.name_s3
  delimiter   = "-"
  label_order = ["namespace", "stage", "name", "attributes"]

  #tags = {
  #  "BusinessUnit" = "XYZ",
  #  "Snapshot"     = "true"
  #}
}
module "label_ses" {
  #checkov:skip=CKV_TF_1
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  label_order = ["stage", "name", "attributes"]
  # name ?
  context = module.label_s3.context
}

###-------------
###   S3
###-------------

# remove delete markers
locals {
  # build prefix list from ses_rule_sets and lifecycle rule for each
  prefixes = [for rule_set, rule in var.ses_rule_sets : rule_set]
  prefix_rules = [for prefix in local.prefixes : {
    enabled                                = true
    id                                     = "cleanup-${prefix}"
    abort_incomplete_multipart_upload_days = 1

    filter_and = {
      prefix = "${prefix}/"
    }
    expiration = {
      days = var.s3_expiration
    }
    noncurrent_version_expiration = {
      newer_noncurrent_versions = var.s3_expiration_noncurrent_versions
      noncurrent_days           = var.s3_expiration_noncurrent_days
    }
    transition                    = null
    noncurrent_version_transition = null
  }]
  #lifecycle_configuration_rules = [
  #  {
  #    enabled = true
  #    id      = "cleanup-mail"
  #
  #    abort_incomplete_multipart_upload_days = 1
  #
  #    filter_and = {
  #      prefix = "${var.ses_rule_set_name}/"
  #    }
  #    expiration = {
  #      days = var.s3_expiration
  #    }
  #    noncurrent_version_expiration = {
  #      newer_noncurrent_versions = var.s3_expiration_noncurrent_versions
  #      noncurrent_days           = var.s3_expiration_noncurrent_days
  #    }
  #    transition                    = null
  #    noncurrent_version_transition = null
  #  }
  #  #,
  #  #{
  #  #  enabled = true
  #  #  id      = "cleanup-delete-markers"
  #  #  expiration = {
  #  #    #days                         = null
  #  #    expired_object_delete_marker = true
  #  #  }
  #  #  abort_incomplete_multipart_upload_days = 1
  #  #  filter_and                             = null
  #  #  transition                             = null
  #  #  noncurrent_version_expiration          = null
  #  #  noncurrent_version_transition          = null
  #  #
  #  #}
  #]
  # skip check
  s3_bucket_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowSESPuts",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ses.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${module.label_s3.id}/*",
          "Condition" : {
            "StringEquals" : {
              "aws:Referer" : data.aws_caller_identity.current.account_id
            }
          }
        }
      ]
    }
  )
}

# https://registry.terraform.io/modules/cloudposse/s3-bucket/aws/latest
# https://github.com/cloudposse/terraform-aws-s3-bucket

module "s3_bucket" {
  #checkov:skip=CKV_TF_1
  source  = "cloudposse/s3-bucket/aws"
  version = "3.0.0"

  context = module.label_s3.context

  acl                = "private"
  enabled            = true
  user_enabled       = false
  versioning_enabled = false
  #allow_encrypted_uploads_only = true
  #allow_ssl_requests_only = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  #kms_master_key_arn =
  #sse_algorithm = "AES256" # is on
  s3_object_ownership           = "BucketOwnerEnforced"
  lifecycle_configuration_rules = local.prefix_rules #local.lifecycle_configuration_rules
  source_policy_documents       = [local.s3_bucket_policy]
}

###-------------
###   SES
###-------------

# https://registry.terraform.io/modules/cloudposse/ses/aws/latest
# https://github.com/cloudposse/terraform-aws-ses
module "ses" {
  #checkov:skip=CKV_TF_1
  source  = "cloudposse/ses/aws"
  version = "0.25.0"

  context = module.label_ses.context

  domain = var.ses_domain
  #ses_user_enabled = false # causes invalid json policy
  create_spf_record = true
  verify_dkim       = true
  verify_domain     = true
  zone_id           = data.aws_route53_zone.self.zone_id
}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_active_receipt_rule_set
resource "aws_ses_receipt_rule_set" "s3" {
  for_each      = var.ses_rule_sets
  rule_set_name = each.key
}
resource "aws_ses_active_receipt_rule_set" "s3" {
  for_each      = var.ses_rule_sets
  rule_set_name = aws_ses_receipt_rule_set.s3[each.key].rule_set_name
}

module "ses_rules" {
  source = "./modules/ses-rules"

  for_each          = var.ses_rule_sets
  s3_bucket_name    = module.s3_bucket.bucket_id
  ses_rule_set_name = each.key
  ses_rules         = each.value.rules
  depends_on        = [aws_ses_active_receipt_rule_set.s3]
}
