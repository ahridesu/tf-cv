variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS (must be in us-east-1)"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name (e.g. www.example.com)"
  type        = string
}

