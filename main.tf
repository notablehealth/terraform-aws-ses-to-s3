
# Reference
#  https://aws.amazon.com/premiumsupport/knowledge-center/ses-receive-inbound-emails/
#  https://tech-universe.net/posts/aws/how-to-receive-mail-in-amazon-ses-and-save-it-in-s3/
#  https://cuddly-octo-palm-tree.com/posts/2021-10-24-aws-email-forwarding-tf/
#  https://github.com/alemuro/terraform-aws-ses-email-forwarding

# https://github.com/cloudposse/terraform-null-label
module "label_s3" {
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
  source      = "cloudposse/label/null"
  version     = "0.25.0"
  label_order = ["stage", "name", "attributes"]
  # name ?
  context = module.label_s3.context
}

###-------------
###   S3
###-------------

# remove delete markers, add prefix,
locals {
  lifecycle_configuration_rules = [
    {
      enabled = true
      id      = "cleanup-mail"

      abort_incomplete_multipart_upload_days = 1

      filter_and = {
        prefix = "${var.s3_prefix}/"
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
    }
    #,
    #{
    #  enabled = true
    #  id      = "cleanup-delete-markers"
    #  expiration = {
    #    #days                         = null
    #    expired_object_delete_marker = true
    #  }
    #  abort_incomplete_multipart_upload_days = 1
    #  filter_and                             = null
    #  transition                             = null
    #  noncurrent_version_expiration          = null
    #  noncurrent_version_transition          = null
    #
    #}
  ]
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
  lifecycle_configuration_rules = local.lifecycle_configuration_rules
  source_policy_documents       = [local.s3_bucket_policy]

  #grants = [
  #  {
  #    id          = "012abc345def678ghi901" # Canonical user or account id
  #    type        = "CanonicalUser"
  #    permissions = ["FULL_CONTROL"]
  #    uri         = null
  #  },
  #  {
  #    id          = null
  #    type        = "Group"
  #    permissions = ["READ", "WRITE"]
  #    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  #  },
  #]
}

###-------------
###   SES
###-------------

# https://registry.terraform.io/modules/cloudposse/ses/aws/latest
# https://github.com/cloudposse/terraform-aws-ses
module "ses" {
  source  = "cloudposse/ses/aws"
  version = "0.22.3"

  context = module.label_ses.context

  domain = var.ses_domain
  #ses_user_enabled = false # causes invalid json policy
  #zone_id       = aws_route53_zone.private_dns_zone.zone_id
  #verify_dkim   = var.verify_dkim
  #verify_domain = var.verify_domain
}

## https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_active_receipt_rule_set


resource "aws_ses_receipt_rule_set" "s3" {
  rule_set_name = "s3"
}
resource "aws_ses_active_receipt_rule_set" "s3" {
  rule_set_name = aws_ses_receipt_rule_set.s3.rule_set_name
}

resource "aws_ses_receipt_rule" "s3" {
  name          = "s3"
  rule_set_name = aws_ses_receipt_rule_set.s3.rule_set_name
  recipients    = var.ses_recipents
  enabled       = true
  scan_enabled  = true # spam and virus scan
  tls_policy    = "Require"
  s3_action {
    bucket_name       = module.s3_bucket.bucket_id
    object_key_prefix = "${var.s3_prefix}/"
    position          = 1
    #kms_key_arn        # message encryption ? AWS or KMS
    #topic_arn
  }
}
