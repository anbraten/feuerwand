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
