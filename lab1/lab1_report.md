##### University: [ITMO University](https://itmo.ru/ru/)
##### Faculty: [FICT](https://fict.itmo.ru)
##### Course: [Network programming](https://itmo-ict-faculty.github.io/network-programming/)
##### Year: 2023/2024
##### Group: K34202
##### Author: Sbitnev Aleksandr
##### Lab: Lab1
##### Date of create: 25.10.2023
##### Date of finished: 25.10.2023

***

# Отчёт по лабораторной работе №1 "Установка CHR и Ansible, настройка VPN"


## **Цель работы:** 
Целью данной работы является развертывание виртуальной машины на базе платформы Yandex.Cloud с установленной системой контроля конфигураций Ansible и установка CHR в VirtualBox.

## **Ход работы:**
### 1. Создание виртальной машины с RouterOS и подключение через WinBox.
С официального сайта Mikrotik качаем .vdi образ диска и WinBox. Создаем новую виртуальную машину и подключаем ранее скаченный .vdi диск, в праметрах сети указываем Сетевой мост и Разрешить всё.
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/1.PNG "Настройка сетевого подключения")

Запускаем виртуальную машину вводим логин admin, а пароль отсутсвует, просто жмем enter. Задаем новый пароль.
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/2.PNG "Запуск CHR")

Открываем WinBox и подключаемся к CHR по мак адресу, логину и паролю.
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/3.PNG "Подключение через WinBox")

Подключение установлено.
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/4.PNG "Успешное подключение")

### 2. Создание виртуальной машины Ubuntu в Яндекс.Облаке и подключение к ней.
Создаем новую виртуальную машину с данными параметрами:
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/5.png "")
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/6.png "")
![](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab1/pics/7.png "")

Для создания SSH ключа используем команду:
<code>ssh-keygen -t ed25519</code>

Для копирования публичного ключа:
<code>cat ~/.ssh/ed25519.pub</code>

Машина создана:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/a40131d8-f698-4dcf-9f7e-035a836e8e2c)

Для подключения используем команду:
<code>ssh -i /home/asd/.ssh/id_ed25519 admin@51.250.87.203</code>
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/b3b91b32-324d-49a1-94bd-c756cbd81df6)


### 3. Настройка VPN сервера.

Установим python3 и Ansible:

<code>sudo apt install python3-pip
ls -la /usr/bin/python3.6
sudo pip3 install ansible
ansible --version</code>

Для создания VPN сервера был выбран OpenVPN Access Server. Его приемуществом является возможноть работы через удобный графический интерфейс.

Для его установки воспользуемсая оригинальной инструкцией с сайта openvpn.com для Ubuntu 22. Последовательно выполним следующие команды:

<code>apt update && apt -y install ca-certificates wget net-tools gnupg
wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main">/etc/apt/sources.list.d/openvpn-as-repo.list
apt update && apt -y install openvpn-as
</code>

После выполнения этих команд получаем сообщение:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/bc364b11-c8c4-406a-8bfd-561d8a4cea31)

Переходим по ссылке https://*публичный_ip_сервера*:943/admin. И попадаем в меню авторизации, вводим выданный логин и пароль.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/b031d137-238a-4222-bda9-a7d4872a02c6)

В настройках сети выбираем TCP и указываем 443 порт.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/7146aa8f-5ec7-4d54-a78e-236facb7ac46)

В настройках VPN отключаем TLS.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/0715cc71-c827-44b5-815a-cee038a5d7d9)

В User Permitions создаем нового пользователя и разрешаем автоматический вход.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/baa1b996-1c9d-4700-919d-071694c6c046)

Во вкладке User Profiles надимаем New Profile и начинается загрузка .ovpn файла.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/c362f49e-33d0-4e1c-a19a-9f0cdd6580cb)

### 4. Подключение CHR.
В WinBox переходим в Files и закидываем скаченный файл конфигурации.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/19af5e57-f453-484b-8d1c-32b8243ee0f6)

Через терминал импортируем сертификаты из файла, используя команду <code>certificate import file-name=*название_файла*</code>.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/3491d291-85cb-41f0-acfd-8f420d68da48)

Сертификаты можно посмотреть в Certificates:                                      
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/abe4e46e-a973-4039-aa14-0ebadc98ab00)

Создадим новый интерфейс:     

* Connect To - публичный ip сервера
* Port - 443
* Mode - ip
* Protocol - tcp
* User - ros
* Password - отсутствует
* Certeficate - ранее импортированный сертификат, оканчивающийся на 1

И жмем Apply:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/acdd4b39-2ea2-40da-9ed8-647bba3308f4)

Готово, соединение установлено. Проверим связанность, пропинговав сервер по внутреннему ip-адресу:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/0a5d3ee1-1b40-417f-95a9-c453c6958038)

## **Вывод:** 
В результате выполнения работы было выполнено развертывание виртуальной машины на базе платформы Yandex.Cloud с установленной системой контроля конфигураций Ansible и установка CHR в VirtualBox.
