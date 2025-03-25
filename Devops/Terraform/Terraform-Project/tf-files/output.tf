output "dns-name" {
    value = "http://${aws_alb.app-lb.dns_name}"
}

output "websiteurl" {
    value = "http://${aws_route53_record.rental.name}"
}