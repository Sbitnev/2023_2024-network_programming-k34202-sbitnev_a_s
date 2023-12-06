
##### University: [ITMO University](https://itmo.ru/ru/)
##### Faculty: [FICT](https://fict.itmo.ru)
##### Course: [Network programming](https://itmo-ict-faculty.github.io/network-programming/)
##### Year: 2023/2024
##### Group: K34202
##### Author: Sbitnev Aleksandr
##### Lab: Lab4
##### Date of create: 03.12.2023
##### Date of finished: 06.12.2023

***

# Отчёт по лабораторной работе №4 "Базовая 'коммутация' и туннелирование используя язык программирования P4"


## **Цель работы:** 
Изучить синтаксис языка программирования P4 и выполнить 2 обучающих задания от Open network foundation для ознакомления на практике с P4.

## **Ход работы:**

### 1. Подготвка к выполнению работы.
#### Склонировать репозиторий p4lang/tutorials
```
sudo git clone https://github.com/p4lang/tutorials
```
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/493bca2f-8d88-472b-ada9-06bf9127a69e)



#### Установить Vagrant и VirtualBox
Установим VirtualBox:
```
sudo apt update
sudo apt install virtualbox
```

Установим Vagrant (Для этого нужно подключится к vpn):
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
```

Проверим версию:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/11861b85-9aa1-426e-9446-9bdff7876967)


#### Перейти в папку cd vm-ubuntu-20.04

#### Используя Vagrant развернуть тестовую среду vagrant up

#### В результате установки у вас появится виртуальная машина с аккаунтами login/password vagrant/vagrant и p4/p4

### 2. Implementing Basic Forwarding.


### 3. Implementing Basic Tunneling.


## **Результаты лабораторной работы:**
2 файла с исправленным программным кодом с расширением .p4.

Схема связи.

Результаты пингов, проверки локальной связности.


## **Вывод:** 
В результате выполнения работы был изучен синтаксис языка программирования P4 и выполнены 2 обучающих задания от Open network foundation для ознакомления на практике с P4.
