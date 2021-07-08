resource "aws_acm_certificate" "verdaccio-certificate" {
  domain_name       = "npm.infomedia.systems"
  validation_method = "DNS"

  tags = {
    Owner = "tyermolenko"
    ProvisionedBy = "terraform"
    Environment = "production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "infomedia-systems" {
  name         = "infomedia.systems"
  private_zone = false
}

resource "aws_route53_record" "verdaccio" {
  for_each = {
    for dvo in aws_acm_certificate.verdaccio-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.infomedia-systems.zone_id
}


resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.verdaccio-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.verdaccio : record.fqdn]
}

output "verdaccio_certificate" {
    value = "alb.ingress.kubernetes.io/certificate-arn: ${aws_acm_certificate.verdaccio-certificate.arn}"
}