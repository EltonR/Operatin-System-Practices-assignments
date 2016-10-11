#!/bin/bash

#Generate the DNS
cabecalho="#
# Delegated nameserver records (someone else provides the SOA)
#
#   &fqdn:ip:x:ttl =>
#
#	NS record x.ns.fqdn as nameserver for fqdn
#	A record mapping x.ns.fqdn -> ip [if ip present]
&10.in-addr.arpa::dns-int.inf.ufsm.br.
&42.18.200.in-addr.arpa::dns-int.inf.ufsm.br.
&inf.ufsm.br::dns-int.inf.ufsm.br.
#"
echo "$cabecalho" > dns.conf;
grep -v '^$' machines.txt | awk -F ' ' '{
if ( $1!="#" ){
	print "="$1".inf.ufsm.br:"$2;
}
}' >> dns.conf;
printf "Cnfs-lsc.inf.ufsm.br:paple.inf.ufsm.br.\n" >> dns.conf;











#Generate the DHCP

cabecalho="####################
## Global options ##
####################

not authoritative;

option domain-name \"inf.ufsm.br\";
option domain-name-servers 200.18.42.3;
option subnet-mask 255.255.255.0;

default-lease-time 7200;
max-lease-time 7200;

ddns-update-style none;

shared-network inf-ufsm-br {"

printf "$cabecalho" > dhcpd.conf;
group=""
ip2=""
grep -v '^$' machines.txt | awk -F ' ' '{
if ( $1!="#" ){
	if( (group != $4) && group != ""){
		print "\t\t}";
	}

	split($2,data,".");
	ip=data[1]"."data[2]"."data[3];
	if( ip=="10.1.1" && ip!=ip2 ){
		if(ip2!=""){
			print "\t}";
		}
		print "\n\t# internal IPs\n\tsubnet 10.1.1.0 netmask 255.255.255.0\n\t{\n\t\tnot authoritative;\n\t\toption routers 10.1.1.1;\n\t\toption broadcast-address 10.1.1.255;\n\t\toption subnet-mask 255.255.255.0;\n\t\toption domain-name-servers 200.18.42.3;"
		ip2=ip;
		group="";
	}
	if( ip=="200.18.42" && ip!=ip2 ){
		if(ip2!=""){
			print "\t}";
		}
		print "\n\tsubnet 200.18.42.0 netmask 255.255.255.0\n\t{\n\t\tauthoritative;\n\t\toption routers 200.18.42.7;\n\t\toption broadcast-address 200.18.42.255;\n\t\toption subnet-mask 255.255.255.0;"
		ip2=ip;
		group="";
	}

	if( group != $4){
		group = $4;
		print "\n\t\t# group "$4;
		print "\t\tgroup {";	
	}
	print "\t\t\thost "$1" { hardware ethernet "$3"; fixed-adress "$2"; }"
}
}' >> dhcpd.conf
printf "\n\t\t}\n\t}\n}\n" >> dhcpd.conf;
