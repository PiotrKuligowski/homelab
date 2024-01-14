data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "document" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    sid    = "3"
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "cert-manager-policy"
  policy = data.aws_iam_policy_document.document.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name               = "cert-manager-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

resource "aws_iam_user" "cert-manager" {
  name = "cert-manager"
  path = "/k3s/"
}

resource "aws_iam_access_key" "cert-manager" {
  user = aws_iam_user.cert-manager.name
}

resource "aws_iam_user_policy" "cert-manager" {
  name   = "cert-manager"
  user   = aws_iam_user.cert-manager.name
  policy = data.aws_iam_policy_document.document.json
}
