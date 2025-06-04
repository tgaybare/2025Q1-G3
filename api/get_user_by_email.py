import json
import boto3
import os

def lambda_handler(event, context):
    dynamodb = boto3.client('dynamodb')
    table_name = os.environ['USERS_TABLE_NAME']
    
    # Obtener el email desde el query string parameter
    email = event.get('queryStringParameters', {}).get('email')
    
    if not email:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Email parameter is required'}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    
    try:
        response = dynamodb.query(
            TableName=table_name,
            IndexName='EmailIndex',
            KeyConditionExpression='email = :email',
            ExpressionAttributeValues={':email': {'S': email}}
        )
        
        if response['Items']:
            return {
                'statusCode': 200,
                'body': json.dumps(response['Items'][0]),
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
