import json
import os
import requests
import base64
import urllib.parse
import boto3
from botocore.exceptions import ClientError

USERS_TABLE_NAME = os.getenv('USERS_TABLE_NAME')

dynamodb = boto3.client('dynamodb')

def get_email_from_id_token(id_token: str) -> str:

    try:
        payload_b64 = id_token.split(".")[1]
        padding = '=' * (-len(payload_b64) % 4)
        payload_json = base64.urlsafe_b64decode(payload_b64 + padding)
        claims = json.loads(payload_json)
        return claims.get("email", "")
    except Exception:
        return ""

def callback_handler(event, context):
    code = event.get('queryStringParameters', {}).get('code')
    if not code:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing 'code'"})
        }

    redirect_base_url = os.getenv('REDIRECT_BASE_URL')
    cognito_domain = os.getenv('COGNITO_DOMAIN')  # e.g. mydomain.auth.us-east-1.amazoncognito.com
    client_id = os.getenv('COGNITO_CLIENT_ID')
    front_redirect_url=os.getenv('FRONT_REDIRECT_URL')



    token_url = f"{cognito_domain}/oauth2/token"
    data = {
        "grant_type": "authorization_code",
        "redirect_uri": f"{redirect_base_url}/callback",
        "code": code,
        "client_id": client_id,
    }
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
    }

    response = requests.post(token_url, data=data, headers=headers)
    if response.status_code != 200:
        print("Token request failed:", response.text)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Token exchange failed"})
        }

    tokens = response.json()
    id_token = tokens.get('id_token')
    email = get_email_from_id_token(id_token)
    auth_token = tokens.get('access_token')

    redirect_url = f"{front_redirect_url}/dashboard?authToken={urllib.parse.quote(auth_token)}"


    try:
        response = dynamodb.put_item(
            TableName=USERS_TABLE_NAME,
            Item={
                'email': {'S': email},
            },
            ConditionExpression="attribute_not_exists(email)"
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            pass
        else:
            raise


    return {
        "statusCode": 302,
        "headers": {
            "Location": redirect_url
        }
    }
