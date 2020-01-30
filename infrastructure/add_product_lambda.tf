data "archive_file" "add_product_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambdas/add_product.py"
  output_path = "${path.module}/lambdas/files/add_product.zip"
}

resource "aws_lambda_function" "add_product_lambda" {
  filename      = data.archive_file.add_product_lambda.output_path
  function_name = "add_product_lambda"
  role          = aws_iam_role.add_product_role.arn
  handler       = "add_product.lambda_handler"

  source_code_hash = filebase64sha256(data.archive_file.add_product_lambda.output_path)

  runtime = local.runtime

  tags = local.tags

  environment {
    variables = {
      "product_catalog_table_name" : aws_dynamodb_table.product_catalog.name
    }
  }
}

resource "aws_cloudwatch_log_group" "add_product" {
  name              = "/aws/lambda/${aws_lambda_function.add_product_lambda.function_name}"
  retention_in_days = 7
}