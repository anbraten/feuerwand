# Drop Various Attacks
fire -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
fire -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN -j DROP
fire -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
fire -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
fire -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
fire -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# Drop LAND (Local Area Network Denial) Packets
# In this attack, a packet is spoofed to make the source address appear as the IP-address of the target.  In other words, the source and destination IP-addresses are the same.
fire -4 -A INPUT -s 127.0.0.0/8 -j DROP

# Drop Null Packets
fire -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Drop excessive RST Packets to avoid Smurf-Attacks
fire -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Drop SYN Flood Packets 
fire -A INPUT -p tcp -m state --state NEW -m limit --limit 2/second --limit-burst 2 -j ACCEPT
fire -A INPUT -p tcp -m state --state NEW -j DROP

# Drop XMAS Packets
fire -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
fire -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Anyone who tried to portscan us is locked out for an entire day.
fire -A INPUT   -m recent --name portscan --rcheck --seconds 86400 -j DROP
fire -6 -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP

# Once the day has passed, remove them from the portscan list
fire -A INPUT   -m recent --name portscan --remove
fire -6 -A FORWARD -m recent --name portscan --remove

# These rules add scanners to the portscan list, and log the attempt.
fire -A INPUT   -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
fire -A INPUT   -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

fire -6 -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
fire -6 -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

# Do not log packets that are going to ports used by SMB
# (Samba / Windows Sharing).
fire -A INPUT -p udp -m multiport --dports 135,445 -j DROP
fire -A INPUT -p udp --dport 137:139 -j DROP
fire -A INPUT -p udp --sport 137 --dport 1024:65535 -j DROP
fire -A INPUT -p tcp -m multiport --dports 135,139,445 -j DROP

fire -6 -A FORWARD -p udp -m multiport --dports 135,445 -j DROP
fire -6 -A FORWARD -p udp --dport 137:139 -j DROP
fire -6 -A FORWARD -p udp --sport 137 --dport 1024:65535 -j DROP
fire -6 -A FORWARD -p tcp -m multiport --dports 135,139,445 -j DROP

# Do not log packets that are going to port used by UPnP protocol.
fire -A INPUT -p udp --dport 1900 -j DROP
fire -6 -A FORWARD -p udp --dport 1900 -j DROP

# Do not log late replies from nameservers.
fire -A INPUT -p udp --sport 53 -j DROP
fire -6 -A FORWARD -p udp --sport 53 -j DROP

# Good practise is to explicately reject AUTH traffic so that it fails fast.
fire -A INPUT -p tcp --dport 113 --syn -m conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
fire -6 -A FORWARD -p tcp --dport 113 --syn -m conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
