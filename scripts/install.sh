#!/bin/bash

sudo -i apt update && sudo apt upgrade -y

sudo -i sed 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' -i /etc/sysctl.conf

sudo -i apt install -y strongswan


sudo bash -c "echo \#Static Routes  >> /etc/network/interfaces"
sudo bash -c "echo up route del -net 0.0.0.0/0 gw `ip route | grep default |egrep '[0-9\.]{6,}[$1]' | awk  {'print $3'}` dev eth0  >> /etc/network/interfaces"
sudo bash -c "echo up route del -net 0.0.0.0/0 gw `ip addr | egrep '[0-9\.]{6,}/24' | awk '{print $2}' | cut -d/ -f1` dev eth0  >> /etc/network/interfaces"

sudo bash -c "cat << EOF > /etc/ipsec.conf
config setup
	strictcrlpolicy=yes
	uniqueids = no
conn %default
	ikelifetime=28800s
	keylife=3600s
	rekeymargin=3m
	keyingtries=3
	keyexchange=ikev1
	authby=secret
	auto=start
	type=tunnel
	leftid=#IP PUBLICO
	leftsubnet=#IP DA REDE
	leftauth=psk

conn vpn
	right=#DNS OU IP PUBLICO REMOTO
	rightid=#DMZ OU IP PUBLICO REMOTO
	rightsubnet=#SUBNET REMOTO
	rightauth=psk
	ike=#CRIPTOGRAFIA E DH
	esp=#CRIPTOGRAFIA E DH 
EOF"

sudo bash -c "cat << EOF > /etc/ipsec.secrets
#IP PUBLICO : PSK \"SENHA_DA_VPNS\"
EOF"

sudo reboot