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
