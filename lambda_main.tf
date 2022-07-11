data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = "lambda_script.py"
    output_path = "lambda_script.zip"
  }
resource "aws_lambda_function" "dr_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = local.resource_name_prefix
  role          = aws_iam_role.lambda_role.arn
  handler       = local.lambda_handler

  source_code_hash = data.archive_file.lambda_zip.output_path
  runtime = local.lambda_runtime
  timeout = local.lambda_timeout
  reserved_concurrent_executions = local.lambda_concurrent_executions
  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnets
  }
  environment {
    variables = {
      MASTER_INSTANCE_COUNT = var.MASTER_INSTANCE_COUNT
      MASTER_VOLUME_SIZE    = var.MASTER_VOLUME_SIZE
      MASTER_INSTANCE_TYPE  = var.MASTER_INSTANCE_TYPE
      SLAVE_INSTANCE_COUNT  = var.SLAVE_INSTANCE_COUNT
      SLAVE_VOLUME_SIZE     = var.SLAVE_VOLUME_SIZE
      SLAVE_INSTANCE_TYPE   = var.SLAVE_INSTANCE_TYPE
      EC2_SUBNET_ID         = var.EC2_SUBNET_ID
      EC2KEY_NAME           = var.EC2KEY_NAME
      MASTER_SG             = var.MASTER_SG
      SLAVE_SG              = var.SLAVE_SG
      SERVICE_ACCESS_SG     = var.SERVICE_ACCESS_SG
      CLUSTER_NAME          = var.CLUSTER_NAME
      RELEASE_LABEL         = var.RELEASE_LABEL
      EMR_BOOTSTRAP_PATH    = var.EMR_BOOTSTRAP_PATH
      EMR_STEP_SCRIPTS_PATH = var.EMR_STEP_SCRIPTS_PATH
      ENV                   = var.ENV
      DFS_REPLICATION       = var.DFS_REPLICATION
    }
  }
}

