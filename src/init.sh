# Setup policies for filter table (drop everything by default)
fire -P INPUT DROP
fire -P OUTPUT DROP

fire -4 -P FORWARD DROP
fire -6 -P FORWARD ACCEPT # allow v6 forward in general (but be careful with incoming traffic!!!)

# Setup policies for nat table
# fire -t nat -P PREROUTING ACCEPT
# fire -t nat -P INPUT ACCEPT
# fire -t nat -P OUTPUT ACCEPT
# fire -t nat -P POSTROUTING ACCEPT

# Setup policies for mangle table
# fire -t mangle -P PREROUTING ACCEPT
# fire -t mangle -P INPUT ACCEPT
# fire -t mangle -P FORWARD ACCEPT
# fire -t mangle -P OUTPUT ACCEPT
# fire -t mangle -P POSTROUTING ACCEPT

# Setup policies for raw table
# fire -t raw -P PREROUTING ACCEPT
# fire -t raw -P OUTPUT ACCEPT

# Setup LOGACCEPT chain
fire-add-chain LOG_ACCEPT
fire -A LOG_ACCEPT -m limit --limit 10/minute -j LOG --log-prefix \"FW [accept]: \"
fire -A LOG_ACCEPT -j ACCEPT

# Setup LOGDROP chain
fire-add-chain LOG_DROP
fire -A LOG_DROP -m limit --limit 10/minute -j LOG --log-prefix \"FW [drop]: \"
fire -A LOG_DROP -j DROP

# Setup LOGREJECT chain
fire-add-chain LOG_REJECT
fire -A LOG_REJECT -m limit --limit 10/minute -j LOG --log-prefix \"FW [reject]: \"
fire -A LOG_REJECT -j REJECT

# Chain for rate limiting connections.
fire-add-chain RATE_LIMIT
fire -A RATE_LIMIT -m state --state NEW -m limit --limit 4/second --limit-burst 12 -j RETURN
fire -A RATE_LIMIT -m state --state NEW -m limit --limit 1/minute --limit-burst 1 -j LOG --log-prefix \"FW [rate-limiting]: \"
fire -A RATE_LIMIT -j DROP

fire-add-chain RATE_LIMIT_ACCEPT
fire -A RATE_LIMIT_ACCEPT -j RATE_LIMIT
fire -A RATE_LIMIT_ACCEPT -j ACCEPT

log "done initializing."
