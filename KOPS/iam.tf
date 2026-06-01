# ─────────────────────────────────────────────────────
# IAM — Kops కి AWS Resources Create చేయడానికి Permissions
# EC2 కి IAM Role attach చేస్తాం — Access Key అక్కర్లేదు!
# ─────────────────────────────────────────────────────

locals {
  kops_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
  ]
}

# EC2 కి Attach చేసే IAM Role
resource "aws_iam_role" "kops_role" {
  name = "kops-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name = "Kops EC2 Role"
  }
}

# Policies attach చేయడం
resource "aws_iam_role_policy_attachment" "kops_policies" {
  for_each   = toset(local.kops_policies)
  role       = aws_iam_role.kops_role.name
  policy_arn = each.value
}

# Instance Profile — EC2 కి attach చేయడానికి
resource "aws_iam_instance_profile" "kops_profile" {
  name = "kops-ec2-instance-profile"
  role = aws_iam_role.kops_role.name
}
