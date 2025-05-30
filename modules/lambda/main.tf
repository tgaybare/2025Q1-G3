data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_lambda_function" "this" {
    function_name = var.name
    role = data.aws_iam_role.lab_role.arn
    handler = "hello_world.lambda_handler"
    runtime = "python3.12"
    filename         = "${var.api_folder}/${var.name}.zip"
    source_code_hash = filebase64sha256("${var.api_folder}/${var.name}.zip")

    environment {
        variables = {
            EC2_MASTER_IP = var.ec2_master_ip
        }
    }
}