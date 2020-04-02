# REST API automatization - update product data

## Instruction

1. Create **update_product** *Lambda* with role as Terraform resource - [aws_lambda_function / aws_iam_role / aws_iam_role_policy](https://www.terraform.io/docs/providers/aws/r/lambda_function.html) - code for **update_product** *Lambda* - `original_lambdas/api/update_product.py` :
    - name: `update_product`
    - runtime: `python3.8` 
    - file: `lambdas/update_product.py`
    - handler: `update_product.lambda_handler`
    - tags:
        * `environment: dev`
        * `project: aws-in-practice`

    1. Create zip file with python code for **update_product** *Lambda*:

        ```
        data "archive_file" "update_product_lambda" {
            type        = "zip"
            source_file = "${path.module}/lambdas/update_product.py"
            output_path = "${path.module}/lambdas/files/update_product.zip"
        }
        ```

    2. Create role for **update_product** *Lambda*:

        ```
        resource "aws_iam_role" "update_product_role" {
            name               = "update_product_role_${terraform.workspace}"
            assume_role_policy = data.template_file.lambda_assume_file.rendered
        }
        ```

    3. Create confgiguration for **update_product** *Lambda*:

        ```
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
        ```

    4. Create CloudWatch log group:

        ```
        resource "aws_cloudwatch_log_group" "update_product" {
            name              = "/aws/lambda/${aws_lambda_function.update_product_lambda.function_name}"
            retention_in_days = 7
        }
        ```

    5. Add permissions for **update_product** *Lambda* to *DynamoDB* and *CloudWatch*:

        ```
        resource "aws_iam_role_policy" "update_product_policy" {
            name = "get_products_policy_${terraform.workspace}"
            role = aws_iam_role.update_product_role.id

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
                    "Resource": "${aws_cloudwatch_log_group.update_product.arn}"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "dynamodb:PutItem", "dynamodb:GetItem"
                    ],
                    "Resource": "${aws_dynamodb_table.product_catalog.arn}"
                }
            ]
        }
        EOF
        }
        ```

2. Modify **update_product** *Lambda* code to use environment variables for name of *DynamoDbB* table and pass it as `product_catalog_table_name` from *tf* file.
    - Python:

        ```
        import os 
        ```

        ```
        table = dynamodb.Table(os.environ["product_catalog_table_name"])
        ```


3. Create API endpoint for **update_product** *Lambda* - [terraform template](https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html):

    1. Create API resource - **product** in **product_catalog_api/products**:

        ```
        resource "aws_api_gateway_resource" "product" {
            rest_api_id = aws_api_gateway_rest_api.product_catalog.id
            parent_id   = aws_api_gateway_resource.products.id
            path_part   = "{id}"
        }
        ```
    
    2. Create API PUT method in **product** resource with `id` as a parameter in url:

        ```
        resource "aws_api_gateway_method" "update_product" {
            rest_api_id   = aws_api_gateway_rest_api.product_catalog.id
            resource_id   = aws_api_gateway_resource.product.id
            http_method   = "PUT"
            authorization = "NONE"
            api_key_required = "true"

            request_parameters = {
                "method.request.path.id" = true
            }
        }
        ```

    3. Add **update_product** *Lambda* to *PUT API* method:

        ```
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
        ```

    4. Add permission to invoke **update_product** *Lambda* from API method:

        ```
        resource "aws_lambda_permission" "apigw_update_product_lambda" {
            statement_id  = "AllowExecutionFromAPIGateway"
            action        = "lambda:InvokeFunction"
            function_name = aws_lambda_function.update_product_lambda.function_name
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
