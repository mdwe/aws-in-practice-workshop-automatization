resource "aws_api_gateway_rest_api" "product_catalog" { 
    name        = "product_catalog_api"
    description = "This is REST API for products"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_api_gateway_resource" "product" {
    rest_api_id = aws_api_gateway_rest_api.product_catalog.id
    parent_id   = aws_api_gateway_rest_api.product_catalog.root_resource_id
    path_part   = "product"
}

resource "aws_api_gateway_method" "add_product" {
    rest_api_id   = aws_api_gateway_rest_api.product_catalog.id
    resource_id   = aws_api_gateway_resource.product.id
    http_method   = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "add_product" {
  rest_api_id             = aws_api_gateway_rest_api.product_catalog.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.add_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_product_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_product_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  
  source_arn = aws_api_gateway_rest_api.product_catalog.execution_arn
}
