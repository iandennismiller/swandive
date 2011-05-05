#!/usr/bin/env python
from Xenadu import XenaduConfig, Perm
env = { 'ssh': { "user": "root", "address": "swandive.example.com" } }
mapping = [
    ['/etc/sysctl.conf', "sysctl.conf", Perm.root_644],
    ['/etc/network/if-up.d/iptables', "iptables", Perm.root_755],
    ['/etc/iptables.conf', "iptables.conf", Perm.root_644],

    # openvpn
    ["/etc/openvpn/server.conf", "openvpn.conf", Perm.root_644],

    # openswan
    ['/etc/ipsec.conf', "vpn/ipsec.conf", Perm.root_644],
    ['/etc/ipsec.secrets', "vpn/ipsec.secrets", Perm.root_600],

    # xl2tpd
    ['/etc/xl2tpd/xl2tpd.conf', "vpn/xl2tpd.conf", Perm.root_644],
    ['/etc/ppp/options.xl2tpd', "vpn/options.xl2tpd", Perm.root_644],
    ['/etc/ppp/chap-secrets', "vpn/chap-secrets", Perm.root_600],
    ]
apt = [
    "openswan",
    "xl2tpd",
    "libssl-dev",
    "openssl",
    ]

XenaduConfig(globals())
