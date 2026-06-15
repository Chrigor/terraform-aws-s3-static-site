# Armazenar site static no Bucket

provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "static_site_bucket" {
  bucket = "static-site-${var.bucket_name}"

  # Organizar os Buckets (Labels)
  tags = {
    Name        = "Static Site Bucket"
    Environment = "Production"
  }
}

# Configuracao de hospedagem de site estatico
resource "aws_s3_bucket_website_configuration" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_site_bucket" {
  bucket = aws_s3_bucket.static_site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Libera leitura publica dos objetos via bucket policy
resource "aws_s3_bucket_policy" "static_site_bucket" {
  depends_on = [aws_s3_bucket_public_access_block.static_site_bucket]

  bucket = aws_s3_bucket.static_site_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site_bucket.arn}/*"
      }
    ]
  })
}

# Envia o index.html para o bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site_bucket.id
  key          = "index.html"
  source       = "${path.module}/site/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/site/index.html")
}

# Envia o 404.html para o bucket
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.static_site_bucket.id
  key          = "404.html"
  source       = "${path.module}/site/404.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/site/404.html")
}

# URL publica do site estatico
output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.static_site_bucket.website_endpoint}"
}
