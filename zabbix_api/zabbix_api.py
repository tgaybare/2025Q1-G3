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
print("✅ Logged into Zabbix.")

def create_host(hostname, ip):
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
    print(new_host)
    return new_host

def get_host_by_name(name):
    host_id = zapi.host.get(filter={"host": [name]}, output=["hostid", "host"])
    if not host_id:
        print(f"❌ Host '{name}' not found.")
        exit(1)
    return host_id[0]['hostid']
    
def get_host_by_ip(ip):
    host_id = zapi.host.get(filter={"ip": [ip]}, output=["hostid", "host"])
    if not host_id:
        print(f"❌ Host '{ip}' not found.")
        exit(1)
    return host_id[0]['hostid']

def get_metric_value_by_id(host_id, metric_key):
    items = zapi.item.get(
        hostids=[host_id],
        search={"key_": metric_key},
        output=["itemid", "name", "lastvalue"]
    )

    if metric_key == "system.cpu.util":
        for item in items:
            if item["name"] == "CPU utilization":
                return float(item["lastvalue"])
    else:
        for item in items:
            return float(item["lastvalue"])

    return None

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

    for h in reversed(history):
        ts = datetime.fromtimestamp(int(h['clock']))
        val = float(h['value'])
        print(f"  {ts} -> {val}")

    print("")



# host = create_host("NewHostName", "44.195.46.190")
host_id_by_ip = get_host_by_ip("44.195.46.190")
host_id_by_name = get_host_by_name("NewHostName")
if host_id_by_ip != host_id_by_name:
    print(f"❌ Host ids are not equal")
    print(f"By name: {host_id_by_name} | By IP: {host_id_by_ip}")
    exit(1)
else:
    print(f"🎯 Host 'NewHostName' ID: {host_id_by_ip}\n")


for metric, key in METRIC_KEYS.items():
    metric_id = get_metric_id(key, host_id_by_ip)
    history_type = 3 if 'proc.num' in key or 'size' in key else 0
    get_history_by_metric(metric_id, history_type, 5)

print("✅ Done.")
