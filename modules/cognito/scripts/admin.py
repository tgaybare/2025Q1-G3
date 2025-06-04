import subprocess
import sys
import boto3
from botocore.exceptions import ClientError

user_pool_id = sys.argv[1]
client_id = sys.argv[2]
email = sys.argv[3]
password = sys.argv[4]
USERS_TABLE_NAME = sys.argv[5]

dynamodb = boto3.client('dynamodb')

# Sign up the user
subprocess.run([
    "aws", "cognito-idp", "sign-up",
    "--client-id", client_id,
    "--username", email,
    "--password", password,
    "--user-attributes", f"Name=email,Value={email}"
], check=False)

# Confirm the user
subprocess.run([
    "aws", "cognito-idp", "admin-confirm-sign-up",
    "--user-pool-id", user_pool_id,
    "--username", email
], check=False)

# Add the user to the DynamoDB table
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