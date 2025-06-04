import json
import os
import boto3
import jwt
from pyzabbix import ZabbixAPI

# === CONFIGURATION ===
EC2_MASTER_IP = os.getenv('EC2_MASTER_IP')
ZABBIX_URL = f'http://{EC2_MASTER_IP}/zabbix'
USERNAME = 'Admin'
PASSWORD = 'zabbix'
LINUX_SERVERS_ID = '2'
LINUX_ZABBIX_AGENT_ACTIVE_ID = '10343'
AGENT_INTERFACE_TYPE_ID = 1
AGENT_PORT = '10050'
HOSTS_TABLE_NAME = os.getenv('HOSTS_TABLE_NAME')

# === INIT ===
zapi = ZabbixAPI(ZABBIX_URL)
zapi.login(USERNAME, PASSWORD)
print("✅ Logged into Zabbix.")

dynamodb = boto3.client('dynamodb')

def create_host_handler(event, context):

    auth_header = event["headers"].get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return {
            "statusCode": 401,
            "body": json.dumps({"error": "Missing or invalid Authorization header"})
        }

    # Extract and decode JWT (without verification)
    token = auth_header.split(" ")[1]
    decoded_token = jwt.decode(token, options={"verify_signature": False})
    
    # Extract user info
    user_email = decoded_token.get("email")
    user_sub = decoded_token.get("sub")
    if not user_email or not user_sub:
        return {
            "statusCode": 401,
            "body": json.dumps({"error": "Invalid token, missing user information"})
        }


    body = json.loads(event["body"])
    hostname = body.get('hostname', None)
    ip = body.get('ip', None)
    if not ip:
        return {
            "statusCode": 400,
            "error": "IP address is required"
            }
    if not hostname:
        return {
                "statusCode": 400,
                "error": "Hostname is required"
                }
    print(f"Creating host: {hostname} with IP: {ip}")
    # Check if host already exists
    existing_host = zapi.host.get(filter={"host": [hostname]}, output=["hostid", "host"])
    if existing_host:
        return {
                "statusCode": 400,
                "error": f"Host '{hostname}' already exists"
                }

    new_host = zapi.host.create({
        "host": hostname,
        "interfaces": [{
            "type": AGENT_INTERFACE_TYPE_ID,
            "main": 1,
            "useip": 1,
            "ip": ip,
            "dns": "",
            "port": AGENT_PORT
        }],
        "groups": [{"groupid": LINUX_SERVERS_ID}],
        "templates": [{"templateid": LINUX_ZABBIX_AGENT_ACTIVE_ID}]
    })

    response = dynamodb.put_item(
        TableName=HOSTS_TABLE_NAME,
        Item={
            'id': {'S': new_host['hostids'][0]},
            'hostname': {'S': hostname},
            'ip': {'S': ip},
            'user_id': {'S': user_email}
        }
    )

    return {
        "statusCode": 200,
        "hostid": new_host['hostids'][0], 
        "hostname": hostname, "ip": ip
        }