# SNS Topic for Email Notifications
resource "aws_sns_topic" "monitoring_alerts" {
  name = var.name
}

# SNS Topic Policy to Allow Publishing
resource "aws_sns_topic_policy" "monitoring_alerts_policy" {
  arn    = aws_sns_topic.monitoring_alerts.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid    = "AllowPublishing"
    effect = "Allow"
    actions = [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    resources = [aws_sns_topic.monitoring_alerts.arn]
  }
}

data "aws_caller_identity" "current" {}