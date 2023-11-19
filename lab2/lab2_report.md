##### University: [ITMO University](https://itmo.ru/ru/)
##### Faculty: [FICT](https://fict.itmo.ru)
##### Course: [Network programming](https://itmo-ict-faculty.github.io/network-programming/)
##### Year: 2023/2024
##### Group: K34202
##### Author: Sbitnev Aleksandr
##### Lab: Lab1
##### Date of create: 19.11.2023
##### Date of finished: 21.11.2023

***

# Отчёт по лабораторной работе №2 "Развертывание дополнительного CHR, первый сценарий Ansible"


## **Цель работы:** 
С помощью Ansible настроить несколько сетевых устройств и собрать информацию о них. Правильно собрать файл Inventory.

## **Ход работы:**

### 1. Создание и настройка второго CHR.

В VirtualBox создадим копию, ссозданной в первой ЛР  виртумальной машины, сбросив все ее настройки.

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/d02995a1-0d24-487e-9ee2-72b423ac1701)

Аналогично первому CHR из первой ЛР подключим его к VPN серверу.

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/7fd674cb-c3a2-4e56-a09e-f0085c958397)

Проверим связанность с помощью ping:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/ef47a4c6-4f68-49a1-b1f3-39221f2c1404)

### 2. Схема сети.

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/7fcd816a-2bf6-4865-94db-534c4869f3ed)

### 3. Настройка CHR при помощи Ansible.

Для работы необходимо установить библиотеку для работы по SSH при помощи команды <code>pip install —user ansible-pylibssh</code>.

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/3918e729-de15-4ee4-afd8-9177037fe597)

Узнаем IP CHR внутри VPN в интерфейсе OpenVPN:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/21b80d7d-45b8-47c7-8ead-f18a1aa5dd2f)

Проверим возможность подключения по SSH с сервера к CHR.

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/3e3877f1-73de-461f-adb5-1be7b3cd861f)

Для настройки Ansible создадим файл инвентаря [hosts.ini](lab2/files/hosts.ini) в котором указаны данные об устройствах для настройки.  

```
[chr]
chr1 ansible_host=172.27.224.4
chr2 ansible_host=172.27.224.5

[chr:vars]
ansible_connection=ansible.netcommon.network_cli
ansible_network_os=community.routeros.routeros
ansible_user=admin
ansible_ssh_pass=12345
```

Проверим корректность при помощи команды <code>ansible -i hosts.ini -m ping chr</code>.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/09d185aa-9b53-48fb-809d-f76fa873e935)

Также создадим [ansible-playbook](lab2/files/ansible-playbook.yml) файл с командами для настройки конфигурации (логин/пароль; NTP Client; OSPF с указанием Router ID):

```
---
- name:  CHR setting
  hosts: chr
  tasks:
    - name: Create users
      routeros_command:
        commands: 
          - /user add name=alex group=read password=stepananton

    - name: Create NTP client
      routeros_command:
        commands:
          - /system ntp client set enabled=yes server=0.ru.pool.ntp.org
        
    - name: OSPF with router ID
      routeros_command:
        commands: 
          - /interface bridge add name=loopback
          - /ip address add address=172.16.0.1 interface=loopback network=172.16.0.1
          - /routing id add disabled=no id=172.16.0.1 name=OSPF_ID select-dynamic-id=""
          - /routing ospf instance add name=ospf-1 originate-default=always router-id=OSPF_ID
          - /routing ospf area add instance=ospf-1 name=backbone
          - /routing ospf interface-template add area=backbone auth=md5 auth-key=admin interface=ether1

    - name: Get facts
      routeros_facts:
        gather_subset:
          - interfaces
      register: output_ospf

    - name: Print output
      debug:
        var: "output_ospf"
```

Запускаем выполнение ansible-playbook при помощи команды:

```
ansible-playbook -i hosts.ini ansible-playbook.yml
```

Результат выполнения:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/bb38560b-e039-456b-9297-9ccfdb1efced)
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/8b83c702-f1ef-4c76-831d-8667388b0bde)

Результат сбора фактов после выполнения ansible-playbook представлен в файле [output.txt](lab2/files/output.txt).

### 4. Проверка конфигурации.

Созданные на машинах пользователи и NTP Clients:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/12d27622-0ed0-4846-8642-219eb4777d30)

Проверка связанности и OSPF:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/d39fe919-c62e-4f03-98ff-6b8dda0303c5)

### 5. Конфигурация роутеров.
[CHR1](lab2/files/output.txt):
```
# 2023-11-19 16:36:52 by RouterOS 7.11.2
# software id = 
#
/interface bridge
add name=loopback
/interface ovpn-client
add certificate=profile-9179119548576678654.ovpn_1 cipher=aes256-cbc \
    connect-to=158.160.105.75 mac-address=02:3C:3B:DC:E1:4B name=\
    ovpn-out1 port=443 user=ros
/disk
set slot1 slot=slot1 type=hardware
set slot2 slot=slot2 type=hardware
set slot3 slot=slot3 type=hardware
set slot4 slot=slot4 type=hardware
set slot5 slot=slot5 type=hardware
set slot6 slot=slot6 type=hardware
set slot7 slot=slot7 type=hardware
set slot8 slot=slot8 type=hardware
set slot9 slot=slot9 type=hardware
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/routing id
add disabled=no id=172.16.0.1 name=OSPF_ID select-dynamic-id=""
add disabled=no id=172.16.0.1 name=OSPF_ID select-dynamic-id=""
/routing ospf instance
add disabled=no name=ospf-1 originate-default=always router-id=OSPF_ID
/routing ospf area
add disabled=no instance=ospf-1 name=backbone
/ip address
add address=172.16.0.1 interface=loopback network=172.16.0.1
/ip dhcp-client
add interface=ether1
/routing ospf interface-template
add area=backbone auth=md5 auth-key=admin disabled=no interfaces=ether1
add area=backbone auth=md5 auth-key=admin disabled=no interfaces=ether1
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=0.ru.pool.ntp.org
```

[CHR2](lab2/files/output.txt):
```
# 2023-11-19 16:36:57 by RouterOS 7.11.2
# software id = 
#
/interface bridge
add name=loopback
/interface ovpn-client
add certificate=profile-3937261090470544774.ovpn_1 cipher=aes256-cbc \
    connect-to=158.160.105.75 mac-address=02:6E:04:8E:2B:C2 name=ovpn-out1 \
    port=443 user=ros
/disk
set slot1 slot=slot1 type=hardware
set slot2 slot=slot2 type=hardware
set slot3 slot=slot3 type=hardware
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/routing id
add disabled=no id=172.16.0.1 name=OSPF_ID select-dynamic-id=""
/routing ospf instance
add disabled=no name=ospf-1 originate-default=always router-id=OSPF_ID
/routing ospf area
add disabled=no instance=ospf-1 name=backbone
/ip address
add address=172.16.0.1 interface=loopback network=172.16.0.1
/ip dhcp-client
add interface=ether1
/routing ospf interface-template
add area=backbone auth=md5 auth-key=admin disabled=no interfaces=ether1
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=0.ru.pool.ntp.org
```

## **Вывод:** 
В результате выполнения работы с помощью Ansible были настроены несколько сетевых устройств и собрана информация о них. Правильно собрать файл Inventory.
