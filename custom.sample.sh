########################################################################
# Setup firewall rules
#
# If you want packets logged use the target LOG_DROP (-j LOG_DROP)
# for logging and dropping the matching packet, LOGACCEPT (-j LOGACCEPT)
# for logging and accepting the matching packet, or LOGREJECT
# (-j LOGREJECT) for logging and rejecting the matching packet.
########################################################################

###############################################################################
#                                                                             #
# INCOMING                                                                    #
#                                                                             #
###############################################################################
fire-add-chain IN_WAN

# ssh
fire -A IN_WAN -p tcp --dport 22 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT

# www
fire -A IN_WAN -p tcp --dport 80 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT
fire -A IN_WAN -p tcp --dport 443 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT

# mail
fire -A IN_WAN -p tcp --dport 25 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT
fire -A IN_WAN -p tcp --dport 587 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT
fire -A IN_WAN -p tcp --dport 993 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT

# dns
fire -A IN_WAN -p tcp --dport 53 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT
fire -A IN_WAN -p udp --dport 53 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT

fire -A IN_WAN -j RETURN

###############################################################################
#                                                                             #
# OUTGOING                                                                    #
#                                                                             #
###############################################################################

# allow all outgoing traffic
fire-add-chain OUT_WAN
fire -A OUT_WAN -j RETURN

###############################################################################
#                                                                             #
# FORWARDING                                                                  #
#                                                                             #
###############################################################################

sysctl net.ipv6.conf.ens3.proxy_ndp=1 > /dev/null

# allow ipv6 webserver behind docker
IPV6_WEB="ffff::eeee"
fire -6 -A FORWARD -d $IPV6_WEB -p tcp --dport 80 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT
fire -6 -A FORWARD -d $IPV6_WEB -p tcp --dport 443 -m conntrack --ctstate NEW -j RATE_LIMIT_ACCEPT
ip -6 neigh add proxy $IPV6_WEB dev ens3

###############################################################################
#                                                                             #
# INTERFACE ASSINGMENTS                                                       #
#                                                                             #
###############################################################################

# eth0
fire -A INPUT -i eth0 -j IN_WAN
fire -A INPUT -i eth0 -j LOG_DROP
# fire -4 -A DOCKER-USER -i eth0 -j IN_WAN
# fire -4 -A DOCKER-USER -i eth0 -j LOG_DROP
fire -A OUTPUT -o eth0 -j OUT_WAN
fire -A OUTPUT -o eth0 -j ACCEPT

# server ip v4
SERVER_IPV4="x.x.x.x"
fire -4 -A INPUT -d $SERVER_IPV4 -j IN_WAN
fire -4 -A INPUT -d $SERVER_IPV4 -j LOG_DROP
# fire -4 -A DOCKER-USER -d $SERVER_IPV4 -j IN_WAN
# fire -4 -A DOCKER-USER -d $SERVER_IPV4 -j LOG_DROP
fire -4 -A OUTPUT -s $SERVER_IPV4 -j OUT_WAN
fire -4 -A OUTPUT -s $SERVER_IPV4 -j ACCEPT

# server ip v6
SERVER_IPV6="ffff::1"
fire -6 -A INPUT -d $SERVER_IPV6 -j IN_WAN
fire -6 -A INPUT -d $SERVER_IPV6 -j LOG_DROP
fire -6 -A OUTPUT -s $SERVER_IPV6 -j OUT_WAN
fire -6 -A OUTPUT -s $SERVER_IPV6 -j ACCEPT

### IMPORTANT
# Drop left incoming v6 trarffic (because default for v6 is ACCEPT)
fire -6 -A FORWARD -i ens3 -j LOG_DROP

###############################################################################
#                                                                             #
# DISABLED                                                                    #
#                                                                             #
###############################################################################

# ...