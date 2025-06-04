import json
import boto3
import os

def lambda_handler(event, context):
    dynamodb = boto3.client('dynamodb')
    table_name = os.environ['HOSTS_TABLE_NAME']
    
    # Obtener el userEmail desde los query parameters
    user_email = event['queryStringParameters']['userEmail']
    
    try:
        response = dynamodb.query(
            TableName=table_name,
            IndexName='UserEmailIndex',
            KeyConditionExpression='user_email = :user_email',
            ExpressionAttributeValues={':user_email': {'S': user_email}}
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps(response['Items']),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
