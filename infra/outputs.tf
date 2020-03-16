output "alb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

output "api_gateway" {
  value = "${aws_api_gateway_deployment.misfits_prod.invoke_url}"
}