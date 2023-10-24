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
Целью данной работы является развертывание виртуальной машины на базе платформы Microsoft Azure с установленной системой контроля конфигураций Ansible и установка CHR в VirtualBox.

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

### 3. Настройка VPN сервера.

