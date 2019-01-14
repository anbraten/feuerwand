# Reset input, output and forward chains
fire-add-chain INPUT
fire-add-chain OUTPUT
# don't flush forward v4 chain to keep docker settings (flush ipv6 FORWARD only)
#fire -F FORWARD
fire-add-chain -4 DOCKER-USER
fire-add-chain -6 FORWARD
