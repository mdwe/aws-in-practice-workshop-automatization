data "archive_file" "get_products_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambdas/get_products.py"
  output_path = "${path.module}/lambdas/files/get_products.zip"
}

resource "aws_lambda_function" "get_products_lambda" {
  filename      = data.archive_file.get_products_lambda.output_path
  function_name = "get_products_lambda_${terraform.workspace}"
  role          = aws_iam_role.get_products_role.arn
  handler       = "get_products.lambda_handler"

  source_code_hash = filebase64sha256(data.archive_file.get_products_lambda.output_path)

  runtime = local.runtime

  tags = local.tags

  environment {
    variables = {
      "product_catalog_table_name" : aws_dynamodb_table.product_catalog.name
    }
  }
}

resource "aws_cloudwatch_log_group" "get_products" {
  name              = "/aws/lambda/${aws_lambda_function.get_products_lambda.function_name}"
  retention_in_days = 7
}