##### University: [ITMO University](https://itmo.ru/ru/)
##### Faculty: [FICT](https://fict.itmo.ru)
##### Course: [Network programming](https://itmo-ict-faculty.github.io/network-programming/)
##### Year: 2023/2024
##### Group: K34202
##### Author: Sbitnev Aleksandr
##### Lab: Lab3
##### Date of create: 30.11.2023
##### Date of finished: 05.12.2023

***

# Отчёт по лабораторной работе №3 "Развертывание Netbox, сеть связи как источник правды в системе технического учета Netbox"


## **Цель работы:** 
С помощью Ansible и Netbox собрать всю возможную информацию об устройствах и сохранить в отдельном файле.

## **Ход работы:**

### 1. Поднятие Netbox.
Netbox будет подниматься на том же сервере, где установлен OpenVPN и Ansible. В ином случае не получится подключить 2 роутера и NetBox сервер к нашему VPN одновременно, так как в бесплатной версии OpenVPN AS поддерживается 2 одновременных подключения.

Воспользуемся [оригинальной инструкцией](https://docs.netbox.dev/en/stable/installation/) для установки NetBox.

Для корректной работы NetBox понадобится следующее ПО:
* Python от 3.8
* PostgreSQL от 12
* Redis от 4.0

#### Установка PostgreSQL Database
```
sudo apt update
sudo apt install -y postgresql
```

#### Установка Redis
```
sudo apt install -y redis-server
```

Проверка статуса:
```
redis-cli ping
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/b9965225-d4c9-44bf-b64f-7b2f2ab84aca)


#### Установка Python
```
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev
```


#### Проверка версий ПО
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/c3af2ff9-5250-417f-8d81-ad547167c528)

#### Создание базы данных
```
sudo -u postgres psql
```

В оболочке введием следующие команды для создания базы данных и пользователя (роли):
```
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD '12345';
ALTER DATABASE netbox OWNER TO netbox;
-- the next two commands are needed on PostgreSQL 15 and later
\connect netbox;
GRANT CREATE ON SCHEMA public TO netbox;
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/30415ced-1bde-4c8e-802f-a695b61e991d)


Проверим статус:
```
psql --username netbox --password --host localhost netbox
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/fa2d4a4f-2adc-443f-a477-0329b6c80fbd)

#### Установка и запуск Netbox
Скачаем git:
```
sudo apt install -y git
```

Склонируем репозиторий с NetBox:
```
sudo mkdir -p /opt/netbox/
cd /opt/netbox/
sudo git clone -b master --depth 1 https://github.com/netbox-community/netbox.git .
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/d28e78fb-b5fe-4497-97e3-8208a1ad4af8)


Перейдем в каталог конфигурации NetBox и создаим копию configuration_example.py с именем configuration.py. Этот файл будет содержать все локальные параметры конфигурации.
```
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py
```

Отредактируем файл [configuration.py](lab3/files/configuration.py). Изменим следующие параметры:
```
ALLOWED_HOSTS = ['*']

DATABASE = {
    'NAME': 'netbox',               # Database name
    'USER': 'netbox',               # PostgreSQL username
    'PASSWORD': 'admin',            # PostgreSQL password
    'HOST': 'localhost',            # Database server
    'PORT': '',                     # Database port (leave blank for default)
    'CONN_MAX_AGE': 300,            # Max database connection age (seconds)
}

REDIS = {
    'tasks': {
        'HOST': 'localhost',      # Redis server
        'PORT': 6379,             # Redis port
        'PASSWORD': '',           # Redis password (optional)
        'DATABASE': 0,            # Database ID
        'SSL': False,             # Use SSL (optional)
    },
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'PASSWORD': '',
        'DATABASE': 1,            # Unique ID for second database
        'SSL': False,
    }
```

Сгенерируем секретный ключ с помощью и укаем его в конфигурации.
```
python3 ../generate_secret_key.py
```

Запустим сценарий обновелния:
```
sudo /opt/netbox/upgrade.sh
```

Создадим суперпользователя:
```
source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox
python3 manage.py createsuperuser
```

Запустим NetBox:
```
python3 manage.py runserver 0.0.0.0:8000 --insecure
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/f2e6867b-ebfc-4302-8fab-d3e9a5566db5)

Теперь веб-интерфейс нетбокса доступен по http://*Публичный_IP_сервера*:8000. Заходим под ранее созданной учетной записью.
![image_2023-12-05_20-59-15](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/c86aa322-0668-44e5-8aea-5947d9dda7c7)


### 2. Заполнение информации о CHR в Netbox.
Создаём сайт, мануфактуру и роль. Создаём 2 роутера. Для добавления ip-адресов была добавлен интерфейс для роутеров(во вкладке devices), позже ip адресам были предоставлены интерфейсы, после роутерам ip.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/24e5423c-b8f5-4069-98c4-9630c58b011f)

### 3. Сбор данных из Netbox используя Ansible.
Установим ansible-модули для Netbox:
```
ansible-galaxy collection install netbox.netbox
```

Создадим файл [netbox_conf_galaxy.yml](lab3/files/netbox_conf_galaxy.yml):
```
plugin: netbox.netbox.nb_inventory
api_endpoint: http://127.0.0.1:8000
token: 1ef9042ee515f716bdad25fe37e4ed531d38c097
validate_certs: True
config_context: False
interfaces: True
```

Токен можно в http://*Публичный_IP_сервера*:8000/user/api-tokens/:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/8a93de7c-5d35-4f47-b760-9579ac04dc66)

Сохраняем вывод скрипта в файл командой:
```
ansible-inventory -v --list -y -i netbox_conf_galaxy.yml > netbox_inventory.yml
```
В [файле](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab3/files/netbox_inventory%20copy.yml) теперь находится информация об устройствах в YAML-формате. После некоторых изменений мы можем использовать данный файл в качестве инвентарного.


### 4. Сценарий, при котором на основе данных из Netbox можно настроить 2 CHR, изменить имя устройства, добавить IP адрес на устройство.
Для начара отредактируем [inventory-файл](lab3/files/inventory/netbox_inventory.yml). Перенесём переменные для подключения к роутерам:
```
  vars:
    ansible_connection: ansible.netcommon.network_cli
    ansible_network_os: community.routeros.routeros
    ansible_user: admin
    ansible_ssh_pass: 12345
```

Напишем [playbook](lab3/files/ansible-playbook.yml) для изменения имени устройства и добавления IP:
```
- name: Setup Routers
  hosts: ungrouped
  tasks:
    - name: "Change names of devicies"
      community.routeros.command:
        commands:
          - /system identity set name="{{ interfaces[0].device.name }}"

    - name: "Change IP-address"
      community.routeros.command:
        commands:
          - /ip address add address="{{ interfaces[0].ip_addresses[0].address }}" interface="{{ interfaces[0].display }}"
```

Запустим playbook:
```
ansible-playbook -i inventory ansible-playbook.yml
```
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/634bb921-fbdd-4ed1-915a-124bf2fcd5a2)


Ip и имена изменились:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/9f27e228-da73-4fe2-b847-836f8d345195)


### 5. Сценарий, позволяющий собрать серийный номер устройства и вносящий серийный номер в Netbox.
```
- name: Get Serial Numbers
  hosts: ungrouped
  tasks:

    - name: "Get Serial Number"
      community.routeros.command:
        commands:
          - /system license print
      register: license

    - name: "Get Name"
      community.routeros.command:
        commands:
          - /system identity print
      register: identity

    - name: Add Serial Number to Netbox
      netbox_device:
        netbox_url: http://127.0.0.1:8000
        netbox_token: 1ef9042ee515f716bdad25fe37e4ed531d38c097
        data:
          name: "{{ identity.stdout_lines[0][0].split()[1] }}"
          serial: "{{ license.stdout_lines[0][0].split()[1] }}"
```

Выплним [сценарий](lab3/files/serial_number-playbook.yml):
```
ansible-playbook -i inventory serial_number-playbook.yml
```
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/2f2bc5b0-a25c-4993-b3b2-bf2b430a5f4f)

Добавленные серийные номера:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/23b70540-2986-436f-93b2-eebb8ef609e8)
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/b83f353d-74ff-4278-bd0c-4b8d7c60fb09)


## **Результаты лабораторной работы:**
[Файл данных из Netbox.](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab3/files/netbox_inventory%20copy.yml)

2 файла сценариев:
1. [Playbook_ip](lab3/files/ansible-playbook.yml) + [inventory-файл](lab3/files/inventory/netbox_inventory.yml)
2. [Playbook_serial_number](lab3/files/serial_number-playbook.yml)

Схема связи.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/dd5ab4ce-e4fa-4e8c-8964-53e4c85d193b)


Результаты пингов, проверки локальной связности.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/72394fd8-6de9-4ec8-b1a2-3f937d6612b5)


## **Вывод:** 
В результате выполнения работы c помощью Ansible и Netbox была собрана вся возможную информацию об устройствах и сохранена в отдельном файле.
