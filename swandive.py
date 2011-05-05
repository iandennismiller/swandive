#!/usr/bin/env python
from Xenadu import XenaduConfig, Perm
env = { 'ssh': { "user": "root", "address": "swandive.example.com" } }
mapping = [
    ['/etc/sysctl.conf', "sysctl.conf", Perm.root_644],
    ]
XenaduConfig(globals())
