#!/usr/bin/env bash -xe

echo -e '[info] Setting hostname'
cat <<EOF >> /etc/hostname
${vpn_hostname}
EOF
hostname -F /etc/hostname


## See https://wiki.strongswan.org/projects/strongswan/wiki/ForwardingAndSplitTunneling
echo -e '[info] Configuring Network'
cat <<EOF >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF


sysctl -p
iptables -t nat -A POSTROUTING -s ${vpc_cidr} -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
iptables -t nat -A POSTROUTING -s ${vpc_cidr} -o eth0 -j MASQUERADE


echo -e '[info] Installing required packages'
DEBIAN_FRONTEND=noninteractive apt-get-y install  \
    strongswan                                    \
    strongswan-plugin-xauth-generic               \
    iptables-persistent



echo -e '[info] Configuring StrongSwan'
cat <<EOF > /etc/ipsec.conf
config setup
   cachecrls=yes
   uniqueids=never
conn cisco
    keyexchange=ikev1
    leftsubnet=${vpc_cidr}
    xauth=server
    leftfirewall=yes
    leftauth=psk
    right=%any
    rightauth=psk
    rightauth2=xauth
    rightsourceip=${vpn_rightip}
    rightdns=${vpn_dns}
    auto=add
EOF


cat <<EOF > /etc/strongswan.conf
charon {
  dns1 = ${vpn_dns}
  cisco_unity = yes
  load_modular = yes
  plugins {
    include strongswan.d/charon/*.conf
    attr {
      # INTERNAL_IP4_DNS
      dns = ${vpn_dns}
      # UNITY_DEF_DOMAIN
      28674 = ${vpc_domain}
      # UNITY_SPLIT_INCLUDE / split-include
      split-include = ${vpc_cidr}
    }
  }
}
include strongswan.d/*.conf
EOF


cat <<EOF > /etc/ipsec.secrets
: PSK "${vpn_psk}"
${vpn_xauth_user} : XAUTH "${vpn_xauth_password}"
EOF


ipsec rereadall
service strongswan restart


echo -e '[info] Completed bootstrap..'
