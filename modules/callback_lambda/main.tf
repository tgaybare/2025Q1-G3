data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_lambda_function" "this" {
    function_name = var.name
    role = data.aws_iam_role.lab_role.arn
    handler = "callback.callback_handler"
    runtime = "python3.12"

    filename         = "${var.api_folder}/${var.name}.zip"
    source_code_hash = filebase64sha256("${var.api_folder}/${var.name}.zip")

    environment {
        variables = {
            REDIRECT_BASE_URL = var.redirect_base_url
        }
    }
}