# Chain for preventing ping flooding - up to 6 pings per second from a single
# source, again with log limiting. Also prevents us from ICMP REPLY flooding
# some victim when replying to ICMP ECHO from a spoofed source.
fire-add-chain ICMPFLOOD
fire -A ICMPFLOOD -m recent --set --name ICMP --rsource
fire -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -m limit --limit 1/sec --limit-burst 1 -j LOG --log-prefix \"FW [ICMP-flood]: \"
fire -A ICMPFLOOD -m recent --update --seconds 1 --hitcount 6 --name ICMP --rsource --rttl -j DROP
fire -A ICMPFLOOD -j ACCEPT

# Permit useful IMCP packet types for IPv4
# Note: RFC 792 states that all hosts MUST respond to ICMP ECHO requests.
# Blocking these can make diagnosing of even simple faults much more tricky.
# Real security lies in locking down and hardening all services, not by hiding.
fire -4 -A INPUT -p icmp --icmp-type 0  -m conntrack --ctstate NEW -j ACCEPT
fire -4 -A INPUT -p icmp --icmp-type 3  -m conntrack --ctstate NEW -j ACCEPT
fire -4 -A INPUT -p icmp --icmp-type 11 -m conntrack --ctstate NEW -j ACCEPT

# Permit needed ICMP packet types for IPv6 per RFC 4890.
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 1   -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 2   -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 3   -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 4   -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 133 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 134 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 135 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 136 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 137 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 141 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 142 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 130 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 131 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 132 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 143 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 148 -j ACCEPT
fire -6 -A INPUT              -p ipv6-icmp --icmpv6-type 149 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 151 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 152 -j ACCEPT
fire -6 -A INPUT -s fe80::/10 -p ipv6-icmp --icmpv6-type 153 -j ACCEPT

fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 1   -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 2   -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 3   -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 4   -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 133 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 134 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 135 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 136 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 137 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 141 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 142 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 130 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 131 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 132 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 143 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 148 -j ACCEPT
fire -6 -A FORWARD              -p ipv6-icmp --icmpv6-type 149 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 151 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 152 -j ACCEPT
fire -6 -A FORWARD -s fe80::/10 -p ipv6-icmp --icmpv6-type 153 -j ACCEPT

# Use ICMPFLOOD chain for preventing ping flooding.
fire -4 -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ICMPFLOOD
fire -6 -A INPUT -p ipv6-icmp --icmpv6-type 128 -j ICMPFLOOD
fire -6 -A FORWARD -p ipv6-icmp --icmpv6-type 128 -j ICMPFLOOD
