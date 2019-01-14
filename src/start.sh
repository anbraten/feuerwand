#! /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/util.sh

########################################################################
# Initialize firewall
########################################################################

log "starting ..."

# Enable ipv4 forwarding
sysctl -w net.ipv4.ip_forward=1 > /dev/null
sysctl -w net.ipv6.conf.default.forwarding=1 > /dev/null
sysctl -w net.ipv6.conf.all.forwarding=1 > /dev/null

# Reset iptables
source ${DIR}/reset.sh

# Initialize iptables
source ${DIR}/init.sh

# Basic rules
source ${DIR}/basic.sh

# Ping protection
source ${DIR}/ping.sh

# General protection
source ${DIR}/protection.sh

# User defined rules
source ${DIR}/../custom.sh

# End
source ${DIR}/end.sh

log "finished loading."

# fire -L -n -v --line-numbers
