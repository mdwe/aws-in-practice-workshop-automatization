# REST API automatization

## Instruction

1. Create *DynamoDB* resource in *Terraform* file - [aws_dynamodb_table](https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html)
    - table name: `product_catalog`
    - hash key: `id` [string]
    - tags:
        * `environment: dev`
        * `project: aws-in-practise`

2. Init terraform project

    ```
    terraform init
    ```

3. Plan changes with terraform plan

    ```
    terraform plan -out=tfplan
    ```

4. Apply changes from plan `tfplan` to AWS environment

    ```
    terraform apply tfplan
    ```

5. Create **add_product** *Lambda* with role as Terraform resource - [aws_lambda_function / aws_iam_role / aws_iam_role_policy](https://www.terraform.io/docs/providers/aws/r/lambda_function.html) - code for **add_product** *Lambda* - `original_lambdas/api/add_product.py` :
    - name: `add_product`
    - runtime: `python3.8` 
    - file: `lambdas/add_product.py`
    - handler: `add_product.lambda_handler`
    - tags:
        * `environment: dev`
        * `project: aws-in-practise`

    1. Create zip file with python code for **add_product** *Lambda*:

        ```
        data "archive_file" "add_product_lambda" {
            type        = "zip"
            source_file = "${path.module}/lambdas/add_product.py"
            output_path = "${path.module}/lambdas/files/add_product.zip"
        }
        ```

    2. Create role for **add_product** *Lambda*:

        ```
        data "template_file" "lambda_assume_file" {
            template = file(
                "${path.module}/templates/service_assume_role.json",
            )
        }

        resource "aws_iam_role" "add_product_role" {
            name               = "add_product_role"
            assume_role_policy = data.template_file.lambda_assume_file.rendered
        }
        ```

    3. Create confgiguration for **add_product** *Lambda*:

        ```
        resource "aws_lambda_function" "add_product_lambda" {
            filename      = data.archive_file.add_product_lambda.output_path
            function_name = "add_product_lambda"
            role          = aws_iam_role.add_product_role.arn
            handler       = "add_product.lambda_handler"

            source_code_hash = filebase64sha256(data.archive_file.add_product_lambda.output_path)

            runtime = "python3.8"

            tags = {
                environment = "dev"
                project     = "aws-in-practise"
            }

            environment {
                variables = {
                "product_catalog_table_name" : aws_dynamodb_table.product_catalog.name
                }
            }
        }
        ```

    4. Create CloudWatch log group:

        ```
        resource "aws_cloudwatch_log_group" "add_product" {
            name              = "/aws/lambda/${aws_lambda_function.add_product_lambda.function_name}"
            retention_in_days = 7
        }
        ```

    5. Add permissions for **add_product** *Lambda* to *DynamoDB* and *CloudWatch*:

        ```
        resource "aws_iam_role_policy" "add_product_policy" {
        name = "add_product_policy"
        role = aws_iam_role.add_product_role.id

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
            "Resource": "${aws_cloudwatch_log_group.add_product.arn}"
                },
            {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem"
            ],
            "Resource": "${aws_dynamodb_table.product_catalog.arn}"
            }
        ]
        }
        EOF
        }
        ```

6. Init new providers from Terraform files and apply changes with terraform

7. Modify **add_product** *Lambda* code to use environment variables for name of *DynamoDbB* table and pass it as `product_catalog_table_name` from *tf* file.
    - Python:

        ```
        import os 
        ```

        ```
        tabel_name = os.environ["product_catalog_table_name"]
        ```
    
    - Terraform (lambda config file):

        ```
        environment {
            variables = {
                "product_catalog_table_name" : aws_dynamodb_table.product_catalog.name
            }
        }
        ```

8. Extract tags and lambda runtime into variables and share them between all resources:
    - Create `variables.tf` file with content:
        
        ```
        locals {
            tags = {
                environment = "dev"
                project = "aws-in-practise"
            }
            runtime = "python3.8"
        }
        ```

    - In terraform file use tags and runtime as variables:
        
        ```
        tags = local.tags
        ```

        ```
        runtime = local.runtime
        ```

9. Verify solution (output - DynamoDB, logs - CloudWatch) manualy from *Lambda* test with payload: 

    ```
    {
        "body": "{\"name\": \"Funky Bear\", \"desc\": \"Money box Funky Bear 16x30 cm blue. Style: modern, vanguard. Material: dolomite\"}"
    }
    ```

10. Create API endpoint for **add_product** *Lambda* - [terraform template](https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html):

    1. Create API Gateway with name **product_catalog_api**: 

        ```
        resource "aws_api_gateway_rest_api" "product_catalog" {
            name        = "product_catalog_api"
            description = "This is REST API for products"

            endpoint_configuration {
                types = ["REGIONAL"]
            }
        }
        ```

    2. Create API resource - **product** in **product_catalog_api**:

        ```
        resource "aws_api_gateway_resource" "product" {
            rest_api_id = aws_api_gateway_rest_api.product_catalog.id
            parent_id   = aws_api_gateway_rest_api.product_catalog.root_resource_id
            path_part   = "product"
        }
        ```
    
    3. Create API POST method in **product** resource:

        ```
        resource "aws_api_gateway_method" "add_product" {
            rest_api_id   = aws_api_gateway_rest_api.product_catalog.id
            resource_id   = aws_api_gateway_resource.product.id
            http_method   = "POST"
            authorization = "NONE"
        }
        ```

    4. Add **add_product** *Lambda* to *POST API* method:

        ```
        resource "aws_api_gateway_integration" "add_product" {
            rest_api_id             = aws_api_gateway_rest_api.product_catalog.id
            resource_id             = aws_api_gateway_resource.product.id
            http_method             = aws_api_gateway_method.add_product.http_method
            integration_http_method = "POST"
            type                    = "AWS_PROXY"
            uri                     = aws_lambda_function.add_product_lambda.invoke_arn
        }
        ```

    5. Add permission to invoke **add_product** *Lambda* from API method:

        ```
        resource "aws_lambda_permission" "apigw_lambda" {
            statement_id  = "AllowExecutionFromAPIGateway"
            action        = "lambda:InvokeFunction"
            function_name = aws_lambda_function.add_product_lambda.function_name
            principal     = "apigateway.amazonaws.com"

            
            source_arn = aws_api_gateway_rest_api.product_catalog.execution_arn
        }
        ```

    6. Test POST API endpoint with *Request Body*:

        ```
        {
            "name": "Funky Bear",
            "desc": "Money box Funky Bear 16x30 cm blue. Style: modern, vanguard. Material: dolomite"
        }
        ```

11. Create new stage - `dev` and deploy API - [terraform template](https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html):

    ```
    resource "aws_api_gateway_deployment" "api-deployment" {
        depends_on  = ["aws_api_gateway_integration.add_product"]
        rest_api_id = aws_api_gateway_rest_api.product_catalog.id
        stage_name  = "dev"
    }
    ```

12. Display url to invoke API endpoints after changes apply - `output.tf`:  

    ```
    output "api-gateway-url" {
        value = aws_api_gateway_deployment.api-deployment.invoke_url
    }
    ```


#### AWS Services: 
*DynamoDB*, *ApiGateway*, *Lambda*, *CloudWatch*, *IAM*    



### Tips and hints
- Unlock terraform state: 

    ```
    terraform force-unlock LOCK_ID
    ```

