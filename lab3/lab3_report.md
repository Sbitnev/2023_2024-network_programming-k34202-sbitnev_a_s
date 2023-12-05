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


### 2. Заполнение всю возможную информацию о CHR в Netbox.


### 3. Используя Ansible и роли для Netbox в тестовом режиме сохраним все данные из Netbox в отдельный файл.


### 4. Написать сценарий, при котором на основе данных из Netbox можно настроить 2 CHR, изменить имя устройства, добавить IP адрес на устройство.


### 5. Написать сценарий, позволяющий собрать серийный номер устройства и вносящий серийный номер в Netbox.


## **Результаты лабораторной работы:**
Файл данных из Netbox.

2 файла сценариев.

Схема связи.

Результаты пингов, проверки локальной связности.


## **Вывод:** 
В результате выполнения работы c помощью Ansible и Netbox была собрана вся возможную информацию об устройствах и сохранена в отдельном файле.
