# introduction

I want to encrypt my Internet traffic when using an unprotected wifi access point, and you probably do too.  The most widely supported, secure way to achieve this is with L2TP and IPsec.  I want to run this on a virtual machine somewhere in the cloud, like on an Amazon EC2 micro instance (approximately $16/month).  **Swandive creates a secure VPN transport in the cloud, letting me encrypt my laptop and iPod touch on the road.**

# requirements

- Amazon EC2 account
- one EC2 SSH keypair
- one EC2 micro instance
- one Amazon Elastic IP address
- Xenadu (http://github.com/iandennismiller/xenadu)

# installation

0. Download Swandive to your local machine

    This will automatically install Xenadu, which is required for Swandive to work.  setup.sh will also generate random passwords that will be used later in the installation.

    ```
    curl -s -L https://github.com/iandennismiller/swandive/tarball/master -o swandive.tgz
    tar xfz swandive.tgz
    cd iandennismiller-swandive*
    ./setup.sh
    ```

0. Launch an EC2 instance of `ami-3e02f257`, and determine its `Elastic IP` and `Private IP address`

    If you need a primer on launching an EC2 machine instance, read the appendix entry "How to prepare an EC2 machine instance", which is at the end of this readme.  Once you have launched an EC2 instance, then do the following:

    1. Go to the EC2 console: https://console.aws.amazon.com/ec2/home

    2. Click Instances, to get a list of all your instances

    3. Click on the instance you just created

    4. Find the `Elastic IP` and `Private IP address`, like the image below:

    ![EC2 example demonstrating where the IP addresses are](https://github.com/iandennismiller/swandive/raw/master/doc/ec2_example.png)

0. Edit `swandive.ini` to set your IP addresses

    swandive.ini is one of the files included with the swandive distribution.  Change `public_ip` (this is Elastic IP) and `private_ip` to match your instance.

    ```
    [xenadu]
    # this is the publicly visible VPN server IP address.
    # if using EC2, this is the "Elastic IP"
    public_ip = 50.XXX.XXX.XXX

    # this is the private IP address Amazon assigned to your ec2 instance
    private_ip = 10.XXX.XXX.XXX
    ```

    Also, take note of `machine_key`, `user_key`, and `user_name`; your VPN client will use these strings to connect with the VPN server.  You should see long, random keys in swandive.ini, but if you instead see _USER_KEY_, then be sure to run setup.sh which will generate random keys for you.

    Unless you need to change how your VPN allocates IP addresses, you don't need to deal with the rest of the settings.

0. Install Swandive

    Swandive is a Xenadu template, which Xenadu must unpack into a system definition.

    ```
    ./swandive.py --template swandive.ini
    mv tmpl_files files && mv files/swandive.py ./swandive.py && chmod 755 ./swandive.py
    ```

    Now our system definition is stored in the dirctory `files`.  The following commands will deploy Swandive to the machine instance.

    ```
    ./swandive.py --apt -v && ./swandive.py --build && ./swandive.py --deploy
    ```

0. Ensure ipsec will start during boot, then reboot

    Here, replace $ELASTIC_IP with `public_ip`, from `swandive.ini`.  If you created this instance using the example in the appendix, then $ELASTIC_IP is already set for you.

    ```
    ssh root@$ELASTIC_IP
    ```

    ```
    update-rc.d -f ipsec remove && update-rc.d -f ipsec defaults
    reboot now
    ```

0. Done

    Swandive is set up, so configure your clients and start using your new VPN.  You can find the authentication (i.e. login) information in `swandive.ini`.

# appendix

## Configuring the OS X VPN client

The following steps demonstrate configuring OS X for use with Swandive, which is very similar to iPhone/iPod/iPad VPN configuration.  The following `swandive.ini` settings will be referred to in this example:

```
[xenadu]
# this is the publicly visible VPN server IP address.
# if using EC2, this is the "Elastic IP"
public_ip = 50.0.0.1

# this is the private IP address Amazon assigned to your ec2 instance
private_ip = 10.0.0.1

# authentication
user_name = vpnuser
user_key = MChw9YbuAnMJHzMlS8GIX1WsJnaNb7S9
machine_key = Dc9QF8oTOc3RBYbxfN8Avoz8AVxAOFeN
```

0. Launch Network Settings, and create a VPN interface

    Click the plus in the lower-left corner, select "VPN" as Interface, and as VPN Type select "L2TP over IPSec".  Name this service "Swandive".

    ![VPN configuration - create VPN interface](https://github.com/iandennismiller/swandive/raw/master/doc/osx vpn config - create vpn interface.png)

0. Configure Swandive VPN Server Address and Account Name

    Now look at `swandive.ini` and copy the `public_ip` into "Server Address." The "Account Name" is the `user_name`.  

    ![VPN configuration - server address and account](https://github.com/iandennismiller/swandive/raw/master/doc/osx vpn config - server address and account.png)

0. Click "Authentication Settings"

    0. Under User Authentication, click "Password" and copy the `user_key` into this field.

    0. Under Machine Authentication, click "Shared Secret" and copy `machine_key` into this field.

    ![VPN configuration - passwords](https://github.com/iandennismiller/swandive/raw/master/doc/osx vpn config - user password and machine secret.png)

0. Click "Advanced" and enable "send all traffic over VPN connection"

    This critical step will make sure to encrypt all of the traffic coming out of your machine.  If you forget this step, then the VPN actually won't do anything useful for you at all!

    ![VPN configuration - passwords](https://github.com/iandennismiller/swandive/raw/master/doc/osx vpn config - send all traffic.png)

0. Connect

    You're done.  Shortly after you click connect, your machine will be given a new IP address like `192.168.79.2`.  If you visit http://whatsmyip.org you should see that your IP address is now reported to be the same as your Swandive `public_ip`.  Success!

## Authentication

0. What is my secret key?

    pre-shared key, secret key, shared secret, password...  these all mean the same thing, in this particular context.  Different VPN clients use slightly different vocabulary, so try to experiment a little bit.

0. Where are the keys?

    The machine key is in `files/ipsec.secrets`, and the user keys are in `files/chap-secrets`.  You can add as many users as you want to chap-secrets.

0. Why are there two keys (user and machine)?

    One key is often called something like "machine key", "system secret", or "machine password", and it is used to make initial contact with the VPN server.  Everyone who contacts this VPN will use the same machine key, in the same way that everyone enters the same password for a wifi access point.  This key is stored in `files/ipsec.secrets`.

    After connecting, the VPN server requires each user to authenticate with a username and password.  This is sometimes called a "user key", "user secret", "user password"...  Each user who connects to the VPN will have their own username and password, which are stored in `files/chap-secrets`.

0. Why use a pre-shared key instead of SSL certificates?

    Using a "pre-shared key" is basically the same as using a password.  Even though SSL certificates would provide better resistance against attack, SSL certificates are not supported by all VPN clients.  As of May 4, 2011 iOS does not support SSL certificates for L2TP/IPsec, and since I want something that would be compatible with the iPhone, there was no choice but to go with pre-shared key.

## How to prepare an EC2 machine instance

0. [Watch this video](http://youtu.be/qzGa9f51IOo?hd=1) to learn how to create an EC2 instance based on `ami-3e02f257`

    http://youtu.be/qzGa9f51IOo?hd=1

    ami-3e02f257 is based on Ubuntu 10.04, and is suitable for Swandive with an EC2 micro instance.  Just a reminder: an EC2 micro instance will cost at least $16/month, if you use the "on demand" pricing.

    This video is based on steps 1-10 of Stratum Security's fantastic tutorial here: http://www.stratumsecurity.com/blog/2010/12/03/shearing-firesheep-with-the-cloud/

0. Set up SSH on your local machine

    Both Amazon EC2 and Xenadu depend on SSH public key login, which is why we created a keypair using the EC2 console. This step will set up your SSH client to automatically use `ec2identity.pem` when connecting to your Swandive host.

    ```
    export ELASTIC_IP=50.XX.XX.XX
    mv ~/Downloads/ec2identity.pem ~/.ssh && chmod 400 ~/.ssh/ec2identity.pem
    echo -e "\nHost $ELASTIC_IP\n  IdentityFile ~/.ssh/ec2identity.pem\n" >> ~/.ssh/config
    ```

0. Now perform a little housekeeping on your new EC2 instance

    0. Connect to your new instance.  

        ```
        ssh ubuntu@$ELASTIC_IP
        ```

        If SSH is properly configured, then you will be greeted with a normal command prompt.

    0. Configure root account for public key login

        ```
        sudo su -
        cp ~ubuntu/.ssh/authorized_keys ~/.ssh/authorized_keys
        chown root:root ~/.ssh/authorized_keys
        ```

        Xenadu requires root access so that it can set permissions when it uploads files.

    0. Generate new passwords for ubuntu and root account

        ```
        perl -e '@c=(48..57,65..90,97..122); foreach (1..12) { print chr($c[rand(@c)]) }'; echo
        passwd ubuntu
        perl -e '@c=(48..57,65..90,97..122); foreach (1..12) { print chr($c[rand(@c)]) }'; echo
        passwd
        ```

        The perl script generates a random string, which you will need to copy into the password field.

    0. Update the system

        ```
        apt-get update && apt-get upgrade -y
        ```

    0. Configure the timezone

        ```
        dpkg-reconfigure tzdata
        ```

    0. Disable a few unnecessary processes

        ```
        initctl stop tty2 && initctl stop tty3 && initctl stop tty4 && initctl stop tty5 && initctl stop tty6
        rm /etc/init/tty2.conf /etc/init/tty3.conf /etc/init/tty4.conf /etc/init/tty5.conf /etc/init/tty6.conf
        ```

    0. Reboot

        ```
        reboot now
        ```

0. Done

    At this point, you have a fully configured EC2 instance that is ready for Swandive.  You can go back to the Swandive installation process now.

## What software does Swandive use?

0. [Xenadu](https://github.com/iandennismiller/xenadu)

    Xenadu is a system configuration tool, and it happens to be a really easy way to package something like Swandive.  Xenadu transforms a template into a system definition, which Xenadu then deploys to a remote system.  It's great for making servers in a web app setting, since it is trivial to make duplicates of an application server or web server with Xenadu.

0. [Openswan](http://openswan.org)

    Among all the IPsec implementations out there (including racoon, freeswan, strongswan, and others) Openswan was the first one I could get working with NAT-T, which is a critical requirement for EC2.  NAT-T is required since EC2 filters all IP traffic except TCP, UDP, and ICMP, but vanilla IPsec/L2TP specifies the use of ESP and AH which are, at the moment, slightly unusual IP traffic.  For example, most consumer routers won't know how to forward AH and ESP packets, so it's a good thing NAT-T finally works (because it avoids the problem).

0. [xl2tpd](http://www.xelerance.com/services/software/xl2tpd/) and pppd

    IPsec creates a secure channel between the VPN server and VPN client, but then L2TP sets up a tunnel that makes your client visible to the VPN server's network.  This step is similar to plugging a network cable into your client machine, and connecting it to the same network as the VPN server.  pppd is responsible for actually assigning your VPN client an IP address.

0. [Ubuntu](http://ubuntu.com)/[Debian](http://debian.org)

    Swandive should run equally well on a Debian- or Ubuntu-based machine instance.  Why use Ubuntu 10.04?  This is what Ubuntu calls a "long-term support" release, which means they will keep fixing 10.04 bugs through April 2015.  This is important for Swandive because it means the current instructions (as of May 2011) will work for the next 4 years.

# License

Copyright (C) 2011 by Ian Dennis Miller

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.