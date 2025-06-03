import json
import boto3
import os

def lambda_handler(event, context):
    dynamodb = boto3.client('dynamodb')
    table_name = os.environ['HOSTS_TABLE_NAME']
    
    # Obtener el userId desde los query parameters
    user_id = event['queryStringParameters']['userId']
    
    try:
        response = dynamodb.query(
            TableName=table_name,
            IndexName='UserIdIndex',
            KeyConditionExpression='user_id = :user_id',
            ExpressionAttributeValues={':user_id': {'S': user_id}}
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
