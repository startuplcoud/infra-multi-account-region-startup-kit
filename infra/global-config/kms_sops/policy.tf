data "aws_iam_policy_document" "policy" {
  policy_id = "sops-deploy-kms"
  statement {
    sid       = "enable iam permission"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
  }
  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    principals {
      identifiers = concat([data.aws_caller_identity.current.arn], var.role_arn_list, var.user_arn_list)
      type        = "AWS"
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      identifiers = [data.aws_caller_identity.current.arn]
      type        = "AWS"
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      values   = ["true"]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}