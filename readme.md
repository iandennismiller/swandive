## introduction

I want to encrypt my Internet traffic when using an unprotected wifi access point, and you probably do too.  The most widely supported, secure way to achieve this is with L2TP and IPsec.  I want to run this on a virtual machine somewhere in the cloud, like on an Amazon EC2 micro instance (approximately $16/month).  *Swandive creates a secure VPN transport in the cloud, letting me encrypt my laptop and iPod touch on the road.*

## requirements

- Amazon EC2 account
- one EC2 SSH keypair
- one EC2 micro instance
- one Amazon Elastic IP address
- Xenadu [http://github.com/iandennismiller/xenadu]

## installation

1. Download and install Xenadu and Swandive

    ```
    curl -L https://github.com/iandennismiller/xenadu/tarball/master -o xenadu.tgz
    curl -L https://github.com/iandennismiller/swandive/tarball/master -o swandive.tgz
    tar xvfz xenadu.tgz
    tar xvfz swandive.tgz
    cd iandennismiller-xenadu*
    python setup.py install
    ```

2. Next, log in to a fresh machine instance.

    If you need a primer on launching an EC2 machine instance, check out the appendix.



# appendix

## How to prepare an EC2 machine instance

For a fantastic overview of this process, be sure to read .

### configure the new instance

```
ssh -i id_rsa-gsg-keypair ubuntu@swandive.example.com
```

```
sudo su -
passwd ubuntu
passwd
apt-get update
apt-get upgrade -y
dpkg-reconfigure tzdata
initctl stop tty2
initctl stop tty3
initctl stop tty4
initctl stop tty5
initctl stop tty6
rm /etc/init/tty2.conf /etc/init/tty3.conf /etc/init/tty4.conf /etc/init/tty5.conf /etc/init/tty6.conf
reboot now
```

### add public key to /root/.ssh
