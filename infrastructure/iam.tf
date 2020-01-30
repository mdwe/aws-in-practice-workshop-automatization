data "template_file" "lambda_assume_file" {
  template = file(
    "${path.module}/templates/service_assume_role.json",
  )
}

####################################################################################
# ADD PRODUCT LAMBDA
####################################################################################
resource "aws_iam_role" "add_product_role" {
  name               = "add_product_role"
  assume_role_policy = data.template_file.lambda_assume_file.rendered
}

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
