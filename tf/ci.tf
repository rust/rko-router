resource "aws_iam_role" "rko-router-deploy" {
  name               = "GhaRkoRouterDeploy"
  description        = "rko-router tf/iam.tf"
  assume_role_policy = data.aws_iam_policy_document.rko-router-deploy-trust.json
}

data "aws_iam_openid_connect_provider" "github-actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "rko-router-deploy-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github-actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:apprunner-prod"
      ]
    }
  }
}

resource "aws_iam_role_policy" "rko-router-deploy-ecr" {
  role   = aws_iam_role.rko-router-deploy.name
  policy = data.aws_iam_policy_document.rko-router-access.json
}

resource "aws_iam_role_policy" "rko-router-deploy-apprunner" {
  role   = aws_iam_role.rko-router-deploy.name
  policy = data.aws_iam_policy_document.rko-router-deploy-apprunner.json
}

data "aws_iam_policy_document" "rko-router-deploy-apprunner" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [aws_iam_role.rko-router-access.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "apprunner:DescribeService",
      "apprunner:UpdateService",
    ]
    resources = [
      aws_apprunner_service.rko-router.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "apprunner:ListServices",
    ]
    resources = ["*"]
  }
}
