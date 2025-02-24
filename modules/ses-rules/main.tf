resource "aws_ses_receipt_rule" "s3" {
  for_each   = var.ses_rules
  name       = each.key
  recipients = each.value.recipients

  rule_set_name = var.ses_rule_set_name
  enabled       = true
  scan_enabled  = true # spam and virus scan
  tls_policy    = "Require"
  s3_action {
    bucket_name       = var.s3_bucket_name
    object_key_prefix = "${var.ses_rule_set_name}/${each.value.prefix}/"
    position          = 1
    #kms_key_arn        # message encryption ? AWS or KMS
    #topic_arn
  }
}
