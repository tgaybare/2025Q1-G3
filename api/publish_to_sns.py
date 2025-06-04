import json
import boto3
import os

dynamodb = boto3.client('dynamodb')
sns = boto3.client('sns')

def publish_to_sns_handler(event, context):
    try:
        # Parse event (from API Gateway or SNS)
        body = json.loads(event.get('body', '{}')) if 'body' in event else event
        host_id = body.get('host_id')
        server_ip = os.environ.get('EC2_MASTER_IP')
        zabbix_url = f"http://{server_ip}/zabbix/"
        alert_message = body.get('alert_message')

        if not host_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'host_id is required'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        # Query Hosts table to get user_id
        response = dynamodb.get_item(
            TableName=os.environ['HOSTS_TABLE_NAME'],
            Key={'id': {'S': host_id}}
        )
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': f'Host {host_id} not found'}),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }

        user_email = response['Item']['user_email']['S']

        # Publish to SNS topic
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject='Zabbix Monitoring Alert',
            Message=f"""
Alert for Host: {host_id}
Message: {alert_message}
Email: {user_email}
Please check your Zabbix dashboard for details: {zabbix_url}
"""
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Notification sent'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }