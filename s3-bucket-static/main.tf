# Armazenar site static no Bucket

provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
  type = "string"
}

resource "aws_s3_bucket" "static_site_bucket" {
  bucket = "static_site-${var.bucket_name}"

  Website {
    index_document = "index.html"
    error_document = "404.html"
  }

  # Organizar os Buckets (Labels)
  tags = { 
    Name       = "Static Site Bucket"
    Enviroment = "Production"
  } 
}

resource "aws_s3_bucket_public_access_block" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Anexa politica
resource "aws_s3_bucket_ownership_controls" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Libera politicas de leitura para todos
resource "aws_s3_bucket_acl" "static_site_bucket" {
  depends_on = [
    aws_s3_bucket_public_access_block.static_site_bucket,
    aws_s3_bucket_ownership_controls.static_site_bucket,
    bucket = aws_s3_bucket.static_site_bucket.id
    acl = "public-read"
  ]
}