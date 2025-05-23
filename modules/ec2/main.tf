resource "aws_instance" "this" {
    ami                    = "ami-084568db4383264d4"
    instance_type          = var.instance_type
    subnet_id              = var.subnet_id
    key_name               = var.key_name
    vpc_security_group_ids = var.security_group_ids

    associate_public_ip_address = var.public
    user_data = templatefile(var.user_data_path, {
        html_content = file("/Users/santiago/Desktop/ITBA/1C2025/CLOUD/static_webpgs/static_webpg_1.html")
    })

    tags = {
        Name = var.instance_name
    }
}