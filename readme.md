## introduction

I want to encrypt my Internet traffic when using an unprotected wifi access point, and you probably do too.  The most widely supported, secure way to achieve this is with L2TP and IPsec.  I want to run this on a virtual machine somewhere in the cloud, like on an Amazon EC2 micro instance (approximately $16/month).  *Swandive creates a secure VPN transport in the cloud, letting me encrypt my laptop and iPod touch on the road.*

## requirements

- Amazon EC2 account
- one EC2 SSH keypair
- one EC2 micro instance
- one Amazon Elastic IP address
- Xenadu (http://github.com/iandennismiller/xenadu)

## installation

0. Download and install Xenadu and Swandive

    Do this on your local machine, not on the cloud machine.

    ```
    curl -L https://github.com/iandennismiller/xenadu/tarball/master -o xenadu.tgz
    curl -L https://github.com/iandennismiller/swandive/tarball/master -o swandive.tgz
    tar xvfz xenadu.tgz
    tar xvfz swandive.tgz
    cd iandennismiller-xenadu*
    python setup.py install
    ```

0. Launch an EC2 instance of `ami-3e02f257`, and determine its `Elastic IP` and `Private IP address`

    1. Go to the EC2 console: https://console.aws.amazon.com/ec2/home

    2. Click Instances, to get a list of all your instances

    3. Click on the instance you just created

    4. Find the `Elastic IP` and `Private IP address`, like in the image below:

    ![Alt text](/path/to/img.jpg)

    If you need a primer on launching an EC2 machine instance, check out the appendix.

0. Edit `swandive.ini` to set your IP addresses and authentication info

    1. Change `public_ip` (Elastic IP) and `private_ip` (Private IP address) to match your instance.

    2. Pick a new `machine_key`, `user_name`, and `user_key`.  The two keys should be random, so the following perl one-liner may be useful in creating new passwords for you.

    ```
    perl -e '@c=(48..57,65..90,97..122);foreach $i (1..32){$p.=chr($c[rand(@c)]);}print $p;'
    ```

    3. You probably don't need to deal with the rest of the settings, unless you need to change how your VPN allocates IP addresses.

0. Edit `swandive.py` to set the ssh address

    Change `swandive.example.com` to the `public_ip` address of your instance:

    ```python
    env = { 'ssh': { "user": "root", "address": "swandive.example.com" } }
    ```

0. Install Swandive on the EC2 instance

    Swandive is really just a Xenadu system definition, which is why we needed to install Xenadu first.

    ```
    ./swandive.py --template swandive.ini
    mv tmpl_files files
    ./swandive.py --apt
    ./swandive.py --build
    ./swandive.py --deploy
    ```

0. Reboot

    Alternatively, log on to your instance and restart ipsec, pppd-dns, and xl2tpd:

    ```
    /etc/init.d/ipsec restart
    /etc/init.d/pppd-dns restart
    /etc/init.d/xl2tpd restart
    ```

0. Done

    Swandive is set up, so configure your clients and start using your new VPN.  The `machine key` is stored in `files/ipsec.secrets`, and the user account information is stored in `files/chap-secrets`.  You will need these to log in.

## Authentication

0. Why use a pre-shared key instead of SSL certificates?

    Using a "pre-shared key" is basically the same as using a password.  Even though SSL certificates would provide better resistance against attack, SSL certificates are not supported by all VPN clients.  As of May 4, 2011 iOS does not support this, and since I want something that would be compatible with the iPhone, there was no choice but to go with pre-shared key.

0. What is my secret key?

    pre-shared key, secret key, shared secret, password...  these all mean basically the same thing.  Different VPN clients use slightly different vocabulary, so try to experiment a little bit.

0. Why are there two keys?

    One key is called something like `machine key`, `system secret`, or `machine password`, and it is used to make initial contact with the VPN server.  Everyone who contacts this VPN will use the same machine key, in the same way that everyone enters the same password for a wifi access point.  This key is stored in `files/ipsec.secrets`.

    After connecting, the VPN server requires you to authenticate with a username and password.  This is the second key, which is sometimes called a 'user key', 'user secret', 'user password'...  Each user who connects to the VPN will have their own username and password, which are stored in `files/chap-secrets`.

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
apt-get update && apt-get upgrade -y
dpkg-reconfigure tzdata
initctl stop tty2 && initctl stop tty3 && initctl stop tty4 && initctl stop tty5 && initctl stop tty6
rm /etc/init/tty2.conf /etc/init/tty3.conf /etc/init/tty4.conf /etc/init/tty5.conf /etc/init/tty6.conf
reboot now
```

### add public key to /root/.ssh
