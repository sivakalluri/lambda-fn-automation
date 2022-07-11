locals {
    prefix                        = "dr_lambda"
    resource_name_prefix          = "${local.prefix}"
    lambda_handler                = "lambda_script.lambda_handler"
    lambda_description            = "Lambda function for DR"
    lambda_runtime                = "python3.9"
    lambda_timeout                = 5
    lambda_concurrent_executions  = -1
  }


