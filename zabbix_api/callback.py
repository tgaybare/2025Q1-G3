import json
import urllib.parse
import os

def callback_handler(event, context):
    code = event.get('queryStringParameters', {}).get('code')
    if not code:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing 'code'"})
        }

    auth_token = f"token_for_{code}"

    redirect_base_url = os.getenv('REDIRECT_BASE_URL')

    redirect_url = f"{redirect_base_url}?authToken={urllib.parse.quote(auth_token)}"

    print(f"Redirecting to: {redirect_url}")

    return {
        "statusCode": 302,
        "headers": {
            "Location": redirect_url
        }
    }
