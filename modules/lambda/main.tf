data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_lambda_layer_version" "this" {
    layer_name = "zabbix_api_layer"
    compatible_runtimes = ["python3.12"]
    filename = "${var.api_folder}/zabbix_api_layer.zip"
    source_code_hash = filebase64sha256("${var.api_folder}/zabbix_api_layer.zip")
}

resource "aws_lambda_function" "this" {
    function_name = var.name
    role = data.aws_iam_role.lab_role.arn
    handler = "get_metrics.get_metrics_handler"
    runtime = "python3.12"
    filename         = "${var.api_folder}/${var.name}.zip"
    source_code_hash = filebase64sha256("${var.api_folder}/${var.name}.zip")
    layers = [aws_lambda_layer_version.this.arn]

    environment {
        variables = {
            EC2_MASTER_IP = var.ec2_master_ip
        }
    }
}