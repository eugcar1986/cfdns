#!/bin/bash
MYIP=$(curl -4 icanhazip.com)
ethernet=`ip route get 8.8.8.8 | awk 'NR==2 {print $1}' RS="dev"`;
if [ $MYIP = "" ]; then
    MYIP=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1`;
fi
MYIP2="s/xxxxxxxxx/$MYIP/g"
MYHOST=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 6`
MYDOMAIN="pitcobra888.net"
MYDNS="$MYHOST.$MYDOMAIN"
CFEmail="eugcar1986@gmail.com"
CFKey="986e74c2ee784620d14afb803490cea23ac43"
CFZoneID="e06baf8cfb3d04f4a6215c49813f4f76"
CFAccID="ec8109280446f1819b811593a9a4448d"
install_cfdns(){
RESULTS="";
REPSONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CFZoneID/dns_records?type=A&content=$MYIP" \
    -H "Content-Type: application/json" \
    -H "X-Auth-Email: $CFEmail" \
    -H "X-Auth-Key: $CFKey" | jq -r '.result[] | "\(.id) \(.content) \(.name)"');
if [ -z "$REPSONSE" ]; then
	RESULTS=$(curl "https://api.cloudflare.com/client/v4/zones/$CFZoneID/dns_records" \
	-H "Content-Type: application/json" \
	-H "X-Auth-Email: $CFEmail" \
	-H "X-Auth-Key: $CFKey" \
	-d '{ "content": "'${MYIP}'", "type": "A", "name": "'${MYDNS}'", "proxied": false }');
	echo ${RESULTS}
else
	IFS=$'\n'
	lst1=$REPSONSE;
	for i in $lst1
	do
		id=$(echo $i | awk '{print $1}');
		ipaddress=$(echo $i | awk '{print $2}');
		server=$(echo $i | awk '{print $3}');
		RESULTS=$(curl "https://api.cloudflare.com/client/v4/zones/$CFZoneID/dns_records/$id" \
		-X PATCH \
		-H "Content-Type: application/json" \
		-H "X-Auth-Email: $CFEmail" \
		-H "X-Auth-Key: $CFKey" \
		-d '{ "content": "'${MYIP}'", "type": "A", "name": "'${MYDNS}'", "proxied": false }');
		echo ${RESULTS}
	done
fi
}
install_cfdns > /dev/null;