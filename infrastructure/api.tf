resource "aws_api_gateway_rest_api" "product_catalog" {
  name        = "product_catalog_api_${terraform.workspace}"
  description = "This is REST API for products"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "products" {
  rest_api_id = aws_api_gateway_rest_api.product_catalog.id
  parent_id   = aws_api_gateway_rest_api.product_catalog.root_resource_id
  path_part   = "products"
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.product_catalog.id
  parent_id   = aws_api_gateway_resource.products.id
  path_part   = "{id}"
}

####################################################################################
# API KEYS
####################################################################################
resource "aws_api_gateway_api_key" "product_catalog_key" {
  name = "product_catalog_key_${terraform.workspace}"
}

resource "aws_api_gateway_usage_plan" "product_catalog_plan" {
  name = "product_catalog_plan_${terraform.workspace}"

  api_stages {
    api_id = aws_api_gateway_rest_api.product_catalog.id
    stage  = aws_api_gateway_deployment.api-deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "api_key" {
  key_id        = aws_api_gateway_api_key.product_catalog_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.product_catalog_plan.id
}


####################################################################################
# API method - POST - add_product_lambda
####################################################################################
resource "aws_api_gateway_method" "add_product" {
  rest_api_id      = aws_api_gateway_rest_api.product_catalog.id
  resource_id      = aws_api_gateway_resource.products.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = "true"
}

resource "aws_api_gateway_integration" "add_product" {
  rest_api_id             = aws_api_gateway_rest_api.product_catalog.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = aws_api_gateway_method.add_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_product_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_add_product_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_product_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.product_catalog.execution_arn}/*/*/*"
}

####################################################################################
# DEPLOYMENT
####################################################################################
resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    aws_api_gateway_integration.add_product,
    aws_api_gateway_integration.get_products,
    aws_api_gateway_integration.update_product
  ]
  rest_api_id = aws_api_gateway_rest_api.product_catalog.id
  stage_name  = "dev"

  variables = {
    deployed_at = timestamp()
  }
}

####################################################################################
# API method - GET - get_products_lambda
####################################################################################
resource "aws_api_gateway_method" "get_products" {
  rest_api_id      = aws_api_gateway_rest_api.product_catalog.id
  resource_id      = aws_api_gateway_resource.products.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = "true"
}

resource "aws_api_gateway_integration" "get_products" {
  rest_api_id             = aws_api_gateway_rest_api.product_catalog.id
  resource_id             = aws_api_gateway_resource.products.id
  http_method             = aws_api_gateway_method.get_products.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_products_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_get_products_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_products_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.product_catalog.execution_arn}/*/*/*"
}


####################################################################################
# API method - PUT - update_product_lambda
####################################################################################
resource "aws_api_gateway_method" "update_product" {
  rest_api_id      = aws_api_gateway_rest_api.product_catalog.id
  resource_id      = aws_api_gateway_resource.product.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = "true"

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "update_product" {
  rest_api_id             = aws_api_gateway_rest_api.product_catalog.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.update_product.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_product_lambda.invoke_arn

  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

resource "aws_lambda_permission" "apigw_update_product_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_product_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.product_catalog.execution_arn}/*/*/*"
}