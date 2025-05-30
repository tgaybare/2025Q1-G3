import os
from pyzabbix import ZabbixAPI
from datetime import datetime

# === CONFIGURATION ===
EC2_MASTER_IP = os.getenv('EC2_MASTER_IP')
ZABBIX_URL = f'http://{EC2_MASTER_IP}/zabbix'
USERNAME = 'Admin'
PASSWORD = 'zabbix'

# === METRICS TO QUERY ===
METRIC_KEYS = {
    "CPU Utilization": "system.cpu.util",
    "Available Memory": "vm.memory.size[available]",
    "Total Memory": "vm.memory.size[total]",
    "Free Swap Space": "system.swap.size[,free]",
    "System Uptime": "system.uptime",
    "Number of Processes Running": "proc.num[,,run]",
}

# === INIT ===
zapi = ZabbixAPI(ZABBIX_URL)
zapi.login(USERNAME, PASSWORD)
    
def get_host_by_ip(ip):
    host_id = zapi.host.get(filter={"ip": [ip]}, output=["hostid", "host"])
    if not host_id:
        print(f"❌ Host '{ip}' not found.")
        exit(1)
    return host_id[0]['hostid']

def get_metric_id(metric_key, host_id):
    items = zapi.item.get(
        hostids=[host_id],
        search={"key_": metric_key},
        output=["itemid", "name", "key_"]
    )

    if not items:
        print(f"  ❌ Metric with key: {metric_key} not found.\n")

    item = items[0]
    print(f"Name: {item['name']} - ItemId: {item['itemid']} - Key: {item['key_']}")
    return item['itemid']

def get_history_by_metric(item_id, history_type, limit):
    history = zapi.history.get(
        itemids=item_id,
        history=history_type,
        sortfield="clock",
        sortorder="DESC",
        limit=limit
    )

    if not history:
        print("  ⚠️ No history data found.\n")

    return history

def get_metrics_handler(event, context):
    params = event.get('queryStringParameters', {})
    host_ip = params.get('host_ip', '')
    host_id_by_ip = get_host_by_ip(host_ip)
    metrics = {}

    for metric, key in METRIC_KEYS.items():
        metric_id = get_metric_id(key, host_id_by_ip)
        history_type = 3 if 'proc.num' in key or 'size' in key else 0
        history = get_history_by_metric(metric_id, history_type, 5)
        if history:
            last_value = history[0]['value']
            timestamp = datetime.fromtimestamp(int(history[0]['clock'])).strftime('%Y-%m-%d %H:%M:%S')
            metrics[metric] = {
                'value': last_value,
                'timestamp': timestamp
            }
        else:
            metrics[metric] = {
                'value': None,
                'timestamp': None
            }
    return {
        'statusCode': 200,
        'body': {
            'host_ip': host_ip,
            'metrics': metrics
        }
    }