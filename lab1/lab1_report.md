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
![](https://github.com/Sbitnev/2022_2023-introduction_in_routing-k33202-sbitnev_a_s/blob/main/lab1/pics/sh.jpg "Схема связи")
Запускаем виртуальную машину вводим логин admin, а пароль отсутсвует, просто жмем enter. Задаем новый пароль.
