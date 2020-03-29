data "archive_file" "update_product_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambdas/update_product.py"
  output_path = "${path.module}/lambdas/files/update_product.zip"
}

resource "aws_lambda_function" "update_product_lambda" {
  filename      = data.archive_file.update_product_lambda.output_path
  function_name = "update_product_lambda_${terraform.workspace}"
  role          = aws_iam_role.update_product_role.arn
  handler       = "update_product.lambda_handler"

  source_code_hash = filebase64sha256(data.archive_file.update_product_lambda.output_path)

  runtime = local.runtime

  tags = local.tags

  environment {
    variables = {
      "product_catalog_table_name" : aws_dynamodb_table.product_catalog.name
    }
  }
}

resource "aws_cloudwatch_log_group" "update_product" {
  name              = "/aws/lambda/${aws_lambda_function.update_product_lambda.function_name}"
  retention_in_days = 7
}