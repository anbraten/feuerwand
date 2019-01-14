#! /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/util.sh

log "clearing ..."

fire -t nat -F
fire -t mangle -F
fire -F
fire -X

fire -P INPUT ACCEPT
fire -P FORWARD ACCEPT
fire -P OUTPUT ACCEPT

log "iptables cleared! COULD BE DANGEROUS!!!"

# fire -L -n -v --line-numbers
