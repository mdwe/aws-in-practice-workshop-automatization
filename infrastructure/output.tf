output "api-gateway-url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}

output "api-gateway-key" {
  value = aws_api_gateway_api_key.product_catalog_key.value
}