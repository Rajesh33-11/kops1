# ─────────────────────────────────────────────────────
# S3 Bucket — Kops State Store
# Kops cluster configuration ఇక్కడ save అవుతుంది
# ─────────────────────────────────────────────────────

resource "aws_s3_bucket" "kops_state" {
  bucket        = var.state_bucket_name
  force_destroy = false

  tags = {
    Name    = "Kops State Store"
    Cluster = var.cluster_name
  }
}

# Versioning ON — rollback కోసం
resource "aws_s3_bucket_versioning" "kops_state" {
  bucket = aws_s3_bucket.kops_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption — security కోసం
resource "aws_s3_bucket_server_side_encryption_configuration" "kops_state" {
  bucket = aws_s3_bucket.kops_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "kops_state" {
  bucket                  = aws_s3_bucket.kops_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
