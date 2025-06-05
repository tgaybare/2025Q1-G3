# TP-CLOUD

## Módulos

### add_endpoint_apigw
Agrega endpoints HTTP a una API Gateway ya creada.

Conecta rutas específicas a funciones Lambda.

Permite la integración entre el frontend y las funciones backend.

### api_gw
Crea un HTTP API Gateway.

Es utilizada como puente entre el frontend en S3 y las funciones Lambda desplegadas.

Gestiona rutas, integraciones y autorizaciones si se requiere.

### callback_lambda
Crea la Lambda encargada de procesar callbacks de Cognito.

Usada principalmente para redirigir correctamente.

Se integra con otros servicios como DynamoDB para registrar datos tras la autenticación.

### cognito
Crea un User Pool, una App Client y un User Pool Domain.

Configura políticas de autenticación basadas en email.

Se utiliza para autenticar usuarios del frontend y emitir tokens JWT.

Crea un usuario admin, lo verifica y lo carga a DynamoDB

### dynamodb
Crea una base de datos NoSQL para registrar usuarios y los hosts EC2 asociados a cada uno.

Permite una relación directa entre recursos monitoreados y sus propietarios.

### ec2
Despliega una instancia EC2 y seguún los parámetros enviados, crea una instancia con Zabbix Server instalado o bien los hosts a monitorear.

Esta instancia actúa como servidor de monitoreo central.

Expone una API interna que puede ser consumida por las Lambdas.

Se le asocia el security group provitso.

### lambda
Permite crear funciones Lambda personalizadas.

Recibe como parámetros el nombre, el handler, la ubicación del archivo ZIP y los nombres de las variables de entorno que se fueran a utilizar.

### rds
Crea una base de datos MySQL.

Es utilizada por Zabbix para almacenar métricas y datos históricos.

Configura parámetros como tamaño, versión y acceso privado dentro de la VPC.

Se le asocia el security group provitso.

### s3
Crea un bucket configurado para servir un sitio web estático.

Aquí se aloja el frontend desarrollado con React.

Permite configurar redirecciones para SPA.

### vpc
Crea una red virtual privada (VPC) para aislar los recursos.

Incluye subnets públicas y privadas, internet gateway y route tables.

Permite segmentar y asegurar adecuadamente la infraestructura desplegada.

## Guía de instalación

1. Instalar terraform
2. Instalar aws cli
3. Instalar python 3
4. Instalar boto3 dentro de python (pip3 install boto3)
5. Instalar node (npm)

## Admin

Se cuenta con una cuenta con las siguientes credenciales para la demo
email: admin@example.com
contraseña: Admin123!@#

### Hosts
No se cuenta con hosts vinculados a dicho usuario, por lo que hay que hacerlo a mano. 
Para esto se debe usar el botón que dice "Add Host" en la página, y en el campo Host Name 
se debe poner obligatoriamente el nombre de la ip que se ve en output y la ip correspondiente en el campo IP Address. 
El output al aplicar terraform apply muestra:
Outputs:
Hostname1 = <ip address>
Hostname2 = <ip address>
Se debe completar entonces con estos datos.
Estas ips son las que hostean los slaves, creadas para esta demo.

## Funciones utilizadas
- templatefile: Renderiza una plantilla utilizando un mapa de variables para reemplazar valores dinámicos.

- file: Lee el contenido de un archivo local y lo devuelve como una cadena de texto.

- filebase64sha256: Calcula el hash SHA256 codificado en base64 de un archivo, se usa para verificar integridad.

- jsonencode: Convierte una estructura de datos de Terraform (mapa, lista, etc.) a una cadena JSON.

- fileset: Devuelve una lista de archivos dentro de un directorio que coinciden con un patrón.

- lookup: Busca un valor en un mapa con una clave específica, y permite definir un valor por defecto si la clave no existe.

- reverse: Invierte el orden de los elementos de una lista.

- split: Divide una cadena de texto en una lista de subcadenas usando un delimitador.

- urlencode: Codifica una cadena de texto de acuerdo con los estándares de URL

## Meta - argumentos
### for_each
- Utilizado 7 veces
- Utilizado para creación de recursos con muchas similutes donde lo unico que variaba eran las variables recibidas. Por ejemplo, la creación de las lambdas y las subredes
### depends_on
- Utilizado 11 veces
- Utilizado para recursos que utlizan otros recursos. Por ejemplo la ec2 dentro de la vpc. Para crear la ec2 tiene que haberse completado la vpc.