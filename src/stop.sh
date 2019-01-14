#! /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/util.sh

log "stopping ..."

# Reset iptables
source ${DIR}/reset.sh

log "stopped"
