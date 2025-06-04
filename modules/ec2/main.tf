resource "aws_instance" "this" {
    ami                    = "ami-084568db4383264d4"
    instance_type          = var.instance_type
    subnet_id              = var.subnet_id
    key_name               = var.key_name
    vpc_security_group_ids = var.security_group_ids

    associate_public_ip_address = var.public
    user_data = templatefile(var.user_data_path, {
        html_content = file("${path.module}/static_webpgs/static_webpg_1.html")
        rds_endpoint = var.rds_endpoint
        rds_port     = var.rds_port
        master_server_ip = var.master_server_ip
        hostname = var.instance_name
    })

    tags = {
        Name = var.instance_name
    }
}