# ZABBIX API

## Estructura general de API calls

```sh
    curl --request POST \
    --url 'https://example.com/zabbix/api_jsonrpc.php' \
    --header 'Content-Type: application/json-rpc' \
    --data '{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}'
```


## Python

Usamos `pyzabbix` para la API:

```python
    from pyzabbix import ZabbixAPI
```

Para iniciar sesión:

```python
    zapi = ZabbixAPI(ZABBIX_URL)
    zapi.login(USERNAME, PASSWORD)
```

### Crear un host

```python
    new_host = zapi.host.create({
        "host": "NewHostName",
        "interfaces": [{
            "type": 1,  # agent
            "main": 1,
            "useip": 1,
            "ip": "192.168.1.100",
            "dns": "",
            "port": "10050"
        }],
        "groups": [{"groupid": "2"}],  # Por ejemplo, "Linux servers"
        "templates": [{"templateid": "10001"}]  # Cambia por el template deseado
    })
```

#### Conseguir id de group y de template

Nosotros usamos como group "Linux servers" - id = 2 y como template "Linux by Zabbix agent active" - id = 10343

```python
    groups = zapi.hostgroup.get(output=["groupid", "name"])

    templates = zapi.template.get(output=["templateid", "name"])
```

### Obtener IDs de múltiples hosts por IP o nombre

#### Por IP

```python
    ips = ["192.168.1.100", "192.168.1.101"]
    hosts_by_ip = zapi.host.get(filter={"ip": ips}, output=["hostid", "host"])
```

#### Por nombre de host

```python
    names = ["host1", "host2"]
    hosts_by_name = zapi.host.get(filter={"host": names}, output=["hostid", "host"])
```

### Eliminar un host

```python
    hostid = "10105"  # ID del host a eliminar
    zapi.host.delete(hostid)
```

### Obtener un ítem específico (métrica) de un host

#### Buscar keys de los items

```python
    items = zapi.item.get(
        output=["itemid", "name", "key_"]
    )
```

#### Buscar el host

```python
    host = zapi.host.get(filter={"host": "MyHost"}, output=["hostid"])[0]
    hostid = host["hostid"]
```

#### Buscar el ítem por su clave

```python
    items = zapi.item.get(
        hostids=hostid,
        search={"key_": "system.cpu.load[percpu,avg1]"},
        output=["itemid", "name", "lastvalue"]
    )
```

#### Buscar el historial de un item por su clave

```python
    history = zapi.history.get(
        itemids=item_id,
        history=history_type,
        sortfield="clock",
        sortorder="DESC",
        limit=limit
    )
```


### Métricas comunes (claves útiles)
    METRIC_KEYS = {
        "CPU Utilization": "system.cpu.util",
        "Available Memory": "vm.memory.size[available]",
        "Total Memory": "vm.memory.size[total]",
        "Free Swap Space": "system.swap.size[,free]",
        "System Uptime": "system.uptime",
        "Number of Processes Running": "proc.num[,,run]"
    }
