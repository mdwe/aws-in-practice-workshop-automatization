data "template_file" "lambda_assume_file" {
  template = file(
    "${path.module}/templates/service_assume_role.json",
  )
}

####################################################################################
# ADD PRODUCT LAMBDA
####################################################################################
resource "aws_iam_role" "add_product_role" {
  name               = "add_product_role_${terraform.workspace}"
  assume_role_policy = data.template_file.lambda_assume_file.rendered
}

resource "aws_iam_role_policy" "add_product_policy" {
  name = "add_product_policy_${terraform.workspace}"
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


####################################################################################
# GET PRODUCTS LAMBDA
####################################################################################
resource "aws_iam_role" "get_products_role" {
  name               = "get_products_role_${terraform.workspace}"
  assume_role_policy = data.template_file.lambda_assume_file.rendered
}

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


####################################################################################
# UPDATE PRODUCT LAMBDA
####################################################################################
resource "aws_iam_role" "update_product_role" {
  name               = "update_product_role_${terraform.workspace}"
  assume_role_policy = data.template_file.lambda_assume_file.rendered
}

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