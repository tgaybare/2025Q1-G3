output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "website_url" {
  value = "http://${aws_s3_bucket.this.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
}

data "aws_region" "current" {
  provider = aws.s3
}