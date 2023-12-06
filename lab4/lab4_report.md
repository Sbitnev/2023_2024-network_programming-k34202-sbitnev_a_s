
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
В данном упражнении нужно дополнить скрипт basic.p4 так, чтобы в сети заработала переадресация IP-пакетов.

Схема связи сохдаваемой сети:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/ede21804-e7e5-45d4-b977-771f01d57815)

#### Шаг 1. Запустим (неполный) код.
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
В этом упражнении нужно реализовать туннелирование. Должна получиться такая сеть:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/96d028ae-e6ee-4187-aa9c-9f825e5695c6)

#### Шаг 1: Реализация базового туннелирования
Нужно дополнить скрипт, добавив в него новый заголовок, таблицу, несколько проверок на валидность, а также дополнить парсер/депарсер, чтобы они обрабатывали дополнительный заголовок.

Перейдем в репозитроий basic_tunnel

Файл basic_tunnel.p4 содержит реализацию базового IP-маршрутизатора. Он также содержит комментарии, помеченные как TODO, которые указывают на функциональность, которую вам нужно реализовать. Полная реализация коммутатора basic_tunnel.p4 сможет пересылать пакеты на основе содержимого пользовательского заголовка инкапсуляции, а также выполнять обычную IP-пересылку, если заголовок инкапсуляции отсутствует в пакете.

Обработка заголовка парсером:
```
// TODO: Update the parser to parse the myTunnel header as well
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_MYTUNNEL: parse_myTunnel;
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_myTunnel {
        packet.extract(hdr.myTunnel);
        transition select(hdr.myTunnel.proto_id) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }

}
```

Создадим новое действие с именем myTunnel_forward, которое просто устанавливает порт выхода. Добавляем таблицу, аналогичную ipv4_lpm, но переадресацию заменяем на туннельную. Обновим блок apply в блоке управления MyIngress, чтобы применить вновь определенную таблицу myTunnel_exact:
```
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    // TODO: declare a new action: myTunnel_forward(egressSpec_t port)
    action myTunnel_forward(egressSpec_t port) {
        standard_metadata.egress_spec = port;
    }

    // TODO: declare a new table: myTunnel_exact
    // TODO: also remember to add table entries!
    table myTunnel_exact {
        key = {
            hdr.myTunnel.dst_id: exact;
        }
        actions = {
            myTunnel_forward;
            drop;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        // TODO: Update control flow
        if (hdr.ipv4.isValid() && !hdr.myTunnel.isValid()) {
            ipv4_lpm.apply();
        }

        if (hdr.myTunnel.isValid()) {
            myTunnel_exact.apply();
        }
    }
}
```

Добавляем новый заголовок в депарсер:
```
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        // TODO: emit myTunnel header as well
        packet.emit(hdr.myTunnel); // Заголовок туннеля
        packet.emit(hdr.ipv4);
    }
}
```

Итоговый файл:[basic_tunnel.p4](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab4/files/basic_tunnel.p4).

#### Шаг 2: Запуск исправленного кода.
Запустим mininet:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/4353992d-b555-4c0e-a7dd-f3267f5fda8b)

Проверим связанность:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/0813c926-5e5d-450d-97b2-f2cbe0a9826a)


Откроем два терминала для h1 и h2 соответственно:
```
xterm h1 h2
```
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/2348b788-dd76-4cf0-876b-e39d87d7e4f7)


Сначала мы протестируем без туннелирования. В xterm h1 отправим сообщение на h2:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/813eb433-ec4d-409d-aeb1-1640c828409f)

Пакет должен быть получен на h2. Если вы изучите полученный пакет, вы увидите, что он состоит из заголовка Ethernet, заголовка IP, заголовка TCP и сообщения. Если вы измените IP-адрес назначения (например, попробуйте отправить на 10.0.3.3), то сообщение не будет получено h2, а вместо этого будет получено h3.

Теперь мы протестируем с туннелированием. 
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/03cd8ab4-aaf4-4648-b881-100053a0bcb3)


В xterm h1 отправим сообщение:
![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/62379132-28c4-4b1a-95cb-dcb9fe437575)

Пакет должен быть получен на h2, даже если этот IP-адрес является адресом h3. Это происходит потому, что коммутатор больше не использует IP-заголовок для маршрутизации, когда в пакете присутствует заголовок MyTunnel.

## **Результаты лабораторной работы:**
2 файла с исправленным программным кодом с расширением .p4.
Implementing Basic Forwarding: [basic.p3](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab4/files/basic.p4).
Implementing Basic Tunneling: [basic_tunnel.p4](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/blob/main/lab4/files/basic_tunnel.p4).

Схема связи.
Implementing Basic Forwarding:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/77b5b629-a942-4d22-bd82-fd448b03d1e1)

Implementing Basic Tunneling:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/187d8d97-8204-4cf5-8239-6c73ac4cd3df)

Результаты пингов, проверки локальной связности.
Implementing Basic Forwarding:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/d8a7c5a4-5e82-4240-8fb5-7c97b64eaae0)


Implementing Basic Tunneling:

![image](https://github.com/Sbitnev/2023_2024-network_programming-k34202-sbitnev_a_s/assets/71010852/6c39afb2-d5ed-4fba-9c0a-a1efb436ac2b)


## **Вывод:** 
В результате выполнения работы был изучен синтаксис языка программирования P4 и выполнены 2 обучающих задания от Open network foundation для ознакомления на практике с P4.
