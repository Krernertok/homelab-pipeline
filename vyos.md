# VyOS

## Commands

### Install VyOS image with defaults

    install image
    # Yes or default value to every question

### Setting up SSH

    configure
    set service ssh port 22
    commit

Copy SSH public key to 'vyos' user's `~/.ssh/authorized_keys`.

    configure
    set service ssh disable-password-authentication
    commit
    save
    exit

### Set up network interfaces

Configure interface connected to home LAN:

    configure
    set interfaces ethernet eth0 description LAN
    set interfaces ethernet eth0 address 192.168.100.101/24
    set protocols static route 0.0.0.0/0 next-hop 192.168.100.1
    commit

Configure interface connected to virtual bridge:

    configure
    set interfaces ethernet eth1 description VLAN
    set interfaces ethernet eth1 address 10.10.10.1/24
    commit
    save

### Configure source NAT

    conf
    set nat source rule 100 description "SNAT for VLAN"
    set nat source rule 100 address 10.10.10.0/24
    set nat source rule 100 outbound interface eth0
    set nat source rule 100 translation address masquerade
    commit
    save

### Configure DNS

    configure
    set service dns forwarding listen-address '10.10.10.1'
    set service dns forwarding allow-from '10.10.10.0/24'
    set service dns forwarding cache-size '0'
    set service dns forwarding name-server 8.8.8.8
    set service dns forwarding name-server 1.1.1.1
    set system name-server 10.10.10.1
    commit
    save

### Configure firewall

    conf
    set firewall name VLAN-WAN default-action accept
    set firewall name VLAN-LOCAL default-action drop
    set firewall name LOCAL-WAN default-action accept
    set firewall name LOCAL-LAN default-action accept

    set firewall name WAN-LOCAL default-action drop
    set firewall name WAN-LOCAL rule 5 description "Allow established/related traffic"
    set firewall name WAN-LOCAL rule 5 state established enable
    set firewall name WAN-LOCAL rule 5 state related enable
    set firewall name WAN-lOCAL rule 5 action accept
    set firewall name WAN-LOCAL rule 10 description "Allow traffic from k1"
    set firewall name WAN-LOCAL rule 10 protocol tcp
    set firewall name WAN-LOCAL rule 10 source address 192.168.100.5/32
    set firewall name WAN-LOCAL rule 10 action accept
    set firewall name WAN-LOCAL rule 20 description "Allow ICMP"
    set firewall name WAN-LOCAL rule 20 protocol icmp
    set firewall name WAN-LOCAL rule 20 state new enable
    set firewall name WAN-LOCAL rule 20 action accept

    set firewall name WAN-VLAN default-action drop
    set firewall name WAN-VLAN rule 5 description "Allow EST/Related Traffic"
    set firewall name WAN-VLAN rule 5 action accept
    set firewall name WAN-VLAN rule 5 state established enable
    set firewall name WAN-VLAN rule 5 state related enable
    set firewall text WAN-VLAN rule 20 description "Allow ICMP"
    set firewall name WAN-VLAN rule 20 protocol icmp
    set firewall name WAN-VLAN rule 20 state new enable
    set firewall name WAN-VLAN rule 20 action accept

    set firewall zone LOCAL local-zone
    set firewall zone LOCAL default-action drop
    set firewall zone LOCAL from VLAN firewall name LAN-LOCAL
    set firewall zone LOCAL from WAN firewall name WAN-LOCAL

    set firewall zone VLAN default-action drop
    set firewall zone VLAN from WAN firewall name WAN-VLAN
    set firewall zone VLAN from LOCAL firewall name LOCAL-VLAN
    set firewall zone VLAN interface eth1

    set firewall zone WAN default-action drop
    set firewall zone WAN from WAN firewall name WAN-VLAN
    set firewall zone WAN from LOCAL firewall name LOCAL-VLAN
    set firewall zone WAN interface eth0

    commit
    save

### Configure port forwarding for SSH connections to VLAN

    conf
    set nat destination rule 100 description "SSH to frontend proxy/jump host"
    set nat destination rule 100 protocol tcp
    set nat destination rule 100 destination port 2222
    set nat destination rule 100 inbound-interface eth0
    set nat destination rule 100 translation address 10.10.10.100
    set nat destination rule 100 translation port 22
    commit
    save

