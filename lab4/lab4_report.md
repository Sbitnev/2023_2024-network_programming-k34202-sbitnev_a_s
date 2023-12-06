
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

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/3c6191bb-6663-49fc-b605-fdfce2712d5c)



#### Установить Vagrant и VirtualBox
Проверим версию:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/f6d23f1a-50a0-4bf8-aeca-642375be6de6)


#### Перейти в папку cd vm-ubuntu-20.04
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/a0d54f68-de6f-4ebf-b835-d38486cca5f4)


#### Используя Vagrant развернуть тестовую среду vagrant up (Опять с подключенным VPN)
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/9e875cb5-c9cb-4a3b-876b-61fd0a8c183a)

#### В результате установки у нас появится виртуальная машина с аккаунтами login/password vagrant/vagrant и p4/p4

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/2c5d908c-3822-469e-863e-7e80c904ddc9)

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/cca7a1fc-e603-4d76-93e7-80860f196c7d)


### 2. Implementing Basic Forwarding.

#### Шаг 1. Запустим (неполный) код.
Схема связи сохдаваемой сети:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/ede21804-e7e5-45d4-b977-771f01d57815)


Заходим в созданную виртуальную машину под учетной записью p4/p4. Переходим в каталог tutorials/exercices/basic. Поднимаем виртуальную сеть Mininet и компилируем basic.p4 командой:

```
make run
```

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/71b47944-cd1a-4180-97b5-4be12885761c)

Попробуем пропинговать хосты:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/885a4bfc-4d8a-4a6c-9559-b51da6df9861)

Ping не удался, поскольку каждый коммутатор запрограммирован в соответствии с basic.p4, который отбрасывает все пакеты по прибытии. 

Выйдем из mininet, остновим и очистим логи:
```
exit
make stop
make clean
```

#### Шаг 2. Редактирование [basic.p3](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab4/files/basic.p4).
Файл basic.p4 содержит заготовку программы P4, в которой ключевые элементы логики заменены комментариями TODO.

Добавим в парсер парсеры для Ethernet и IPv4, заполняющие поля ethernet_t и ipv4_t.
```
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start { transition parse; }

    state parse{
      packet.extract(hdr.ethernet);
      transition select(hdr.ethernet.etherType) {
        TYPE_IPV4: parse_ipv4;
        default: accept;
        }
    }
      
    state parse_ipv4{
      packet.extract(hdr.ipv4);
      transition accept;
    }
}
```

Напишем действие (называемое ipv4_forward), которое:
* Устанавливает порт выхода для следующего узла.
* Обновляет MAC-адрес назначения Ethernet на адрес следующего узла.
* Обновляет MAC-адрес источника Ethernet на адрес коммутатора.
* Уменьшает значение TTL.

Добавим таблицу маршрутизации и условие проверки заголовка IPv4.

```
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec= port; // Изменяем порт
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr; // Меняем адрес источника на свой
        hdr.ethernet.dstAddr = dstAddr; // Устанавливаем нового получателя
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1; // Декрементируем TTL
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm; // ключ таблицы
        }
        actions = {       // возможные действия
            ipv4_forward; 
            drop;
            NoAction;
        }
        size = 1024;    // размер таблицы
        default_action = NoAction(); // действие по умолчанию
    }

    apply {
        if(hdr.ipv4.isValid()){ // Недостающая часть (проверка)
          ipv4_lpm.apply();
        }
    }
```

Напишем депарсер, который выбирает порядок вставки полей в исходящий пакет.
```
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
    }
}
```

Итоговый файл: [basic.p3](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab4/files/basic.p4).

#### Шаг 3. Запуск исправленного кода.
Аналогично шагу 1 выполним команды:
```
make run
```

Выполним ping.
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/4bc2e677-2da4-4d62-bfb7-1c5841b1dc49)


### 3. Implementing Basic Tunneling.


## **Результаты лабораторной работы:**
2 файла с исправленным программным кодом с расширением .p4.

Схема связи.

Результаты пингов, проверки локальной связности.


## **Вывод:** 
В результате выполнения работы был изучен синтаксис языка программирования P4 и выполнены 2 обучающих задания от Open network foundation для ознакомления на практике с P4.
