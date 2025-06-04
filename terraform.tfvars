vpc_cidr            = "10.0.0.0/16"
# subnet1_cidr        = "10.0.1.0/24"
# subnet2_cidr        = "10.0.2.0/24"
# subnet3_cidr        = "10.0.3.0/24"
# subnet4_cidr        = "10.0.4.0/24"
# key_name            = "ec2_key_pair"
master_server_name = "ec2-master" # master_instance_name = "ec2-master"
# slave_instance_name  = "ec2-slave"
master_server_instance_type = "t2.small" # master_instance_type = "t2.small"
# slave_instance_type  = "t2.micro"
master_security_group_name = "ec2-master-sg"
# slave_security_group_name  = "ec2-slave-sg"
lambda_names = {
    get_metrics = {
        handler = "get_metrics.get_metrics_handler"
        method = "GET"
        env_vars = ["EC2_MASTER_IP"]
    }
    create_host = {
        handler = "create_host.create_host_handler"
        method = "POST"
        env_vars = ["EC2_MASTER_IP", "HOSTS_TABLE_NAME", "SNS_TOPIC_ARN"]
    }
    get_hosts_by_user_id = {
        handler = "get_hosts_by_user_id.lambda_handler"
        method = "GET"
        env_vars = ["HOSTS_TABLE_NAME"]
    }
    publish_to_sns = {
        handler = "publish_to_sns.publish_to_sns_handler"
        method = "POST"
        env_vars = ["SNS_TOPIC_ARN", "EC2_MASTER_IP", "HOSTS_TABLE_NAME"]
    }
}
master_server_user_data_path = "./modules/ec2/scripts/master.sh"
slave_server_user_data_path = "./modules/ec2/scripts/slave.sh"
slave_server_html_content = "./modules/ec2/static_webpgs/static_webpg_1.html"

db_name                 = "zabbix"
db_username             = "admin"
db_password             = "password"
db_instance_class       = "db.t4g.micro"
db_allocated_storage    = 20
db_engine_version       = "8.0.41"
multi_az                = false
publicly_accessible     = false
backup_retention_period = 7
maintenance_window      = "Mon:00:00-Mon:03:00"

api_folder = "./api"

react_app_bucket_region = "us-east-1"