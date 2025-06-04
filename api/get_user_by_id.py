import json
import boto3
import os

def lambda_handler(event, context):
    dynamodb = boto3.client('dynamodb')
    table_name = os.environ['USERS_TABLE_NAME']
    
    # Obtener el ID desde el path parameter
    user_id = event['pathParameters']['id']
    
    try:
        response = dynamodb.get_item(
            TableName=table_name,
            Key={'id': {'S': user_id}}
        )
        
        if 'Item' in response:
            return {
                'statusCode': 200,
                'body': json.dumps(response['Item']),
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'User not found'}),
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
