IP4TABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"

### Config
DRYRUN=false #debug with echo
DATEFORMAT="%b %e %H:%M:%S"

log () {
  echo "[$(date +"$DATEFORMAT")] Firewall: $1"
}

fire-run () {
  eval "$@"

  #"${@:1:1}-save" | grep -q -F -- "$(echo ${@:2})"
  #if [ "$?" == 1 ]; then
  #  eval "$@"
  #else
  #  echo "rule already added"
  #fi
}

fire () {
  args=$@
  if [ "$DRYRUN" = true ]; then
    if [ "$1" == '-4' ]; then
      echo "$IP4TABLES ${@:2}"
    elif [ "$1" == '-6' ]; then
      echo "$IP6TABLES ${@:2}"
    else
      echo "$IP4TABLES $@"
      echo "$IP6TABLES $@"
    fi
  else
    if [ "$1" == '-4' ]; then
      fire-run $IP4TABLES ${@:2}
    elif [ "$1" == '-6' ]; then
      fire-run $IP6TABLES ${@:2}
    else
      fire-run $IP4TABLES $@
      fire-run $IP6TABLES $@
    fi
  fi
}

fire-add-chain () {
  version=""
  chain=$1
  if [ "$1" == '-4' ]; then
    version="-4"
    chain=$2
  elif [ "$1" == '-6' ]; then
    version="-6"
    chain=$2
  fi
  fire $version -F $chain 2> /dev/null # Flush chain
  fire $version -X $chain 2> /dev/null # Delete chain
  fire $version -Z $chain 2> /dev/null # Zero the packet and byte counters
  fire $version -N $chain 2> /dev/null # Create chain
}


