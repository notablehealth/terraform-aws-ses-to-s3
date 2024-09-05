data "aws_caller_identity" "current" {}
#data "aws_iam_account_alias" "current" {}
#data "aws_region" "current" {}

data "aws_route53_zone" "self" {
  name = var.ses_domain
  #private_zone = true
}
