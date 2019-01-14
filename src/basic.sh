# Accept all loopback traffic
fire -A INPUT -i lo -j ACCEPT
fire -A OUTPUT -o lo -j ACCEPT

# Accept all established or related inbound connections
fire -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept all established or related outbound connections
fire -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Accept all established or related forwarding (v4: docker-user, v6: forward) connections
fire -4 -A DOCKER-USER -m state --state RELATED,ESTABLISHED -j ACCEPT
fire -6 -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow outgoing icmp (e.g. ping)
fire -4 -A OUTPUT -p icmp -j ACCEPT
fire -6 -A OUTPUT -p ipv6-icmp -j ACCEPT

# Drop non-conforming packets, such as malformed headers, etc.
fire -A INPUT -m conntrack --ctstate INVALID -j DROP
fire -4 -A DOCKER-USER -m conntrack --ctstate INVALID -j DROP
fire -6 -A FORWARD -m conntrack --ctstate INVALID -j DROP

# Block remote packets claiming to be from a loopback address.
fire -4 -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP
fire -6 -A INPUT -s ::1/128 ! -i lo -j DROP
fire -6 -A FORWARD -s ::1/128 ! -i lo -j DROP

### Broadcasting protection ###

# Drop all packets that are going to broadcast, multicast or anycast address.
fire -4 -A INPUT -m addrtype --dst-type BROADCAST -j DROP
fire -4 -A INPUT -m addrtype --dst-type MULTICAST -j DROP
fire -4 -A INPUT -m addrtype --dst-type ANYCAST -j DROP
fire -4 -A INPUT -d 224.0.0.0/4 -j DROP