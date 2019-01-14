# Feuerwand

An iptables framework for ipv4 & ipv6 with basic protection (rate limiting) and docker support.

## Installation

```
git clone https://github.com/Garogat/feuerwand.git
cd feuerwand
cp custom.sample.sh custom.sh
```

Edit `custom.sh` and adjust everything to your needs.

### Automatic start after boot
`crontab -e`

simply add

`@reboot /yourpath/feuerwand start`

and you are done.
