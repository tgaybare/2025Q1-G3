import os
from pyzabbix import ZabbixAPI
from datetime import datetime

# === CONFIGURATION ===
ZABBIX_URL = os.getenv('ZABBIX_URL')
USERNAME = 'Admin'
PASSWORD = 'zabbix'
HOST_NAME = 'Zabbix server'
LINUX_SERVERS_ID = '2'
LINUX_ZABBIX_AGENT_ACTIVE_ID = '10343'
AGENT_INTERFACE_TYPE_ID = 1
AGENT_PORT = '10050'

# === INIT ===
zapi = ZabbixAPI(ZABBIX_URL)
zapi.login(USERNAME, PASSWORD)
print("✅ Logged into Zabbix.")

def create_host_handler(event, context):
    hostname = event.get('hostname', HOST_NAME)
    ip = event.get('ip', None)
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
    return {
        "statusCode": 200,
        "hostid": new_host['hostids'][0], 
        "hostname": hostname, "ip": ip
        }