resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
   {
    "Sid": "Stmt1649919261065",
    "Action": [
                  "logs:*",
                  "ec2:*"
              ],
    "Effect": "Allow",
    "Resource": "*"
    }
  ]
}
)
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.name}-lambda-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
       "Action" = "sts:AssumeRole",
        "Effect" = "Allow",
        "Sid"    = "",
        "Principal" = {
          "Service" = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

