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

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/7a0c187f-1f18-4a13-b4d7-57795c48166a)

#### Установка Python
```
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev
```


#### Проверка версий ПО
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/ec57564b-a59a-40f5-9db1-fc7a8926db50)

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

Проверим статус:
```
psql --username netbox --password --host localhost netbox
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/fa2d4a4f-2adc-443f-a477-0329b6c80fbd)

#### Установка Netbox
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
