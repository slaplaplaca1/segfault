#! /bin/bash

# CY="\e[1;33m" # yellow
# CG="\e[1;32m" # green
CR="\e[1;31m" # red
CC="\e[1;36m" # cyan
# CM="\e[1;35m" # magenta
# CW="\e[1;37m" # white
CB="\e[1;34m" # blue
CF="\e[2m"    # faint
CN="\e[0m"    # none

# CBG="\e[42;1m" # Background Green

# night-mode
CDY="\e[0;33m" # yellow
CDG="\e[0;32m" # green
# CDR="\e[0;31m" # red
CDB="\e[0;34m" # blue
CDC="\e[0;36m" # cyan
CDM="\e[0;35m" # magenta
CUL="\e[4m"
# BINDIR="$(cd "$(dirname "${0}")" || exit; pwd)"

# shellcheck disable=SC1091
source "/config/guest/vpn_status" 2>/dev/null

if [[ -z $IS_VPN_CONNECTED ]]; then
	VPN_DST="VPN Exit Node     : ${CR}TOR ${CF}(no VPN)${CN}"
else
	i=0
	while [[ $i -lt ${#VPN_GEOIP[@]} ]]; do
		str="Exit ${VPN_PROVIDER[$i]}                          "
		VPN_DST+="${str:0:17} : "
		str="${VPN_EXIT_IP[$i]}                 "
		VPN_DST+="${CDG}${str:0:15}"
		str="${VPN_GEOIP[$i]}"
		[[ ! -z $str ]] && VPN_DST+=" ${CF}(${str})"
		VPN_DST+="${CN}"$'\n'
		((i++))
	done
	# VPN_DST="${CDG}${VPN_EXIT_IP} ${CF}(${VPN_LOCATION:-UNKNOWN})${CN}"
fi
[[ -f "/config/self/ip" ]]    &&    YOUR_IP="$(</config/self/ip)"
[[ -f "/config/self/geoip" ]] && YOUR_GEOIP="$(</config/self/geoip)"

loc="${YOUR_IP:-UNKNOWN}                 "
loc="${loc:0:15}"
[[ -n $YOUR_GEOIP ]] && loc+=" ${CF}($YOUR_GEOIP)"

[[ -f /config/self/reverse_ip ]] && {
	IPPORT="${CDY}$(</config/self/reverse_ip):$(</config/self/reverse_port)"
	[[ -f /config/self/reverse_geoip ]] && IPPORT+=" ${CF}($(<config/self/reverse_geoip))"
}
[[ -z $IPPORT ]] && IPPORT="${CDR}N/A${CN}"

echo -e "\
Your workstation  : ${CDY}${loc}${CN}
${VPN_DST}\
TOR Proxy         : ${CDG}${SF_TOR:-UNKNOWN}:9050${CN}
Reverse Port      : ${IPPORT}${CN}
Shared storage    : ${CDM}/everyone ${CF}(encrypted)${CN}
Your storage      : ${CDM}/sec      ${CF}(encrypted)${CN}"
[[ -e /config/guest/onion_hostname-80 ]] && {
	echo -e "\
Your Onion WWW    : ${CDM}/onion    ${CF}(encrypted)${CN}"

	echo -e "\
Your Web Page     : ${CB}${CUL}http://$(cat /config/guest/onion_hostname-80)/${SF_HOSTNAME,,}/${CN}"
}
[[ -n $SF_SSH_PORT ]] && PORTSTR=" -p${SF_SSH_PORT} "
echo -e "\
SSH               : ${CC}ssh${CDC} -o \"SetEnv SECRET=${SF_SEC:-UNKNOWN}\"${PORTSTR} ${CR}${CF}\\ ${CDC}\n\
                       ${SF_USER:-UNKNOWN}@${SF_FQDN:-UNKNOWN}${CN}"

[[ -e /config/guest/onion_hostname-22 ]] && {
	echo -e "\
SSH (TOR)         : ${CC}torsocks ssh${CN}${CDC} -o \"SetEnv SECRET=${SF_SEC:-UNKNOWN}\" ${CR}${CF}\\ ${CDC}\n\
                       ${SF_USER:-UNKNOWN}@$(cat /config/guest/onion_hostname-22)${CN}"
}
[[ -e /config/guest/gsnc-access-22.txt ]] && {
	echo -e "\
SSH (gsocket)     : ${CC}gsocket -s $(cat /config/guest/gsnc-access-22.txt) ssh${CDC} -o \"SetEnv SECRET=${SF_SEC:-UNKNOWN}\" ${CR}${CF}\\ ${CDC}\n\
                       ${SF_USER:-UNKNOWN}@${SF_FQDN%.*}.gsocket${CN}"
}

