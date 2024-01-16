resource "aws_s3_bucket" "myBucket" {
  bucket = "day67-bucket"
  tags = {
    Name = "Day 67 Bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "myBucket" {
  bucket = aws_s3_bucket.myBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

}

resource "aws_s3_bucket_public_access_block" "myBucket" {
  bucket                  = aws_s3_bucket.myBucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "myBucket" {
  bucket     = aws_s3_bucket.myBucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.myBucket, aws_s3_bucket_public_access_block.myBucket]
}

resource "aws_s3_bucket_policy" "Allow_access_from_another_account" {
  bucket = aws_s3_bucket.myBucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [680579562058]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.myBucket.arn,
      "${aws_s3_bucket.myBucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_versioning" "myBucket_versioning" {
  bucket = aws_s3_bucket.myBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
