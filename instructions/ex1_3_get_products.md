# REST API automatization - get products data

## Instruction

1. Create **get_products** *Lambda* with role as Terraform resource - [aws_lambda_function / aws_iam_role / aws_iam_role_policy](https://www.terraform.io/docs/providers/aws/r/lambda_function.html) - code for **get_products** *Lambda* - `original_lambdas/api/get_products.py` :
    - name: `get_products`
    - runtime: `python3.8` 
    - file: `lambdas/get_products.py`
    - handler: `get_products.lambda_handler`
    - tags:
        * `environment: dev`
        * `project: aws-in-practice`

    1. Create zip file with python code for **get_products** *Lambda*:

        ```
        data "archive_file" "get_products_lambda" {
            type        = "zip"
            source_file = "${path.module}/lambdas/get_products.py"
            output_path = "${path.module}/lambdas/files/get_products.zip"
        }
        ```

    2. Create role for **get_products** *Lambda*:

        ```
        resource "aws_iam_role" "get_products_role" {
            name               = "get_products_role_${terraform.workspace}"
            assume_role_policy = data.template_file.lambda_assume_file.rendered
        }
        ```

    3. Create confgiguration for **get_products** *Lambda*:

        ```
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
        ```

    4. Create CloudWatch log group:

        ```
        resource "aws_cloudwatch_log_group" "get_products" {
            name              = "/aws/lambda/${aws_lambda_function.get_products_lambda.function_name}"
            retention_in_days = 7
        }
        ```

    5. Add permissions for **get_products** *Lambda* to *DynamoDB* and *CloudWatch*:

        ```
        resource "aws_iam_role_policy" "get_products_policy" {
            name = "get_products_policy_${terraform.workspace}"
            role = aws_iam_role.get_products_role.id

            policy = <<EOF
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "Logging",
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "${aws_cloudwatch_log_group.get_products.arn}"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "dynamodb:Scan"
                    ],
                    "Resource": "${aws_dynamodb_table.product_catalog.arn}"
                }
            ]
        }
        EOF
        }
        ```

2. Modify **get_products** *Lambda* code to use environment variables for name of *DynamoDbB* table and pass it as `product_catalog_table_name` from *tf* file.
    - Python:

        ```
        import os 
        ```

        ```
        table = dynamodb.Table(os.environ["product_catalog_table_name"])
        ```


3. Create API endpoint for **get_products** *Lambda* - [terraform template](https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html):
    
    1. Create API GET method in **products** resource:

        ```
        resource "aws_api_gateway_method" "get_products" {
            rest_api_id   = aws_api_gateway_rest_api.product_catalog.id
            resource_id   = aws_api_gateway_resource.products.id
            http_method   = "GET"
            authorization = "NONE"
        }
        ```

    2. Add **get_products** *Lambda* to *GET API* method:

        ```
        resource "aws_api_gateway_integration" "get_products" {
            rest_api_id             = aws_api_gateway_rest_api.product_catalog.id
            resource_id             = aws_api_gateway_resource.products.id
            http_method             = aws_api_gateway_method.get_products.http_method
            integration_http_method = "POST"
            type                    = "AWS_PROXY"
            uri                     = aws_lambda_function.get_products_lambda.invoke_arn
        }
        ```

    3. Add permission to invoke **get_products** *Lambda* from API method:

        ```
        resource "aws_lambda_permission" "apigw_get_products_lambda" {
            statement_id  = "AllowExecutionFromAPIGateway"
            action        = "lambda:InvokeFunction"
            function_name = aws_lambda_function.get_products_lambda.function_name
            principal     = "apigateway.amazonaws.com"

            source_arn = "${aws_api_gateway_rest_api.product_catalog.execution_arn}/*/*/*"
        }
        ```

4. Deploy terraform changes into AWS environment: 

    ```
    terraform plan -out=tfplan
    ```

    ```
    terraform apply "tfplan"
    ```


#### AWS Services: 
*DynamoDB*, *ApiGateway*, *Lambda*, *CloudWatch*, *IAM*    
