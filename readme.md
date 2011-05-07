# introduction

I want to encrypt my Internet traffic when using an unprotected wifi access point, and you probably do too.  The most widely supported, secure way to achieve this is with L2TP and IPsec.  I want to run this on a virtual machine somewhere in the cloud, like on an Amazon EC2 micro instance (approximately $16/month).  **Swandive creates a secure VPN transport in the cloud, letting me encrypt my laptop and iPod touch on the road.**

# requirements

- Amazon EC2 account
- one EC2 SSH keypair
- one EC2 micro instance
- one Amazon Elastic IP address
- Xenadu (http://github.com/iandennismiller/xenadu)

# installation

0. **Download Swandive to your local machine**

    This will automatically install Xenadu, which is required for Swandive to work.  setup.sh will also generate random passwords that will be used later in the installation.

    ```
    curl -s -L https://github.com/iandennismiller/swandive/tarball/master -o swandive.tgz
    tar xfz swandive.tgz
    cd iandennismiller-swandive*
    ./setup.sh
    ```

0. **Launch an EC2 instance of `ami-3e02f257`, and determine its "Elastic IP" and "Private IP address"**

    If you need a primer on launching an EC2 machine instance, read [How to prepare an EC2 machine instance](https://github.com/iandennismiller/swandive/blob/master/doc/ec2_howto.md).  This document also explains how to configure an EC2 security policy, so if you're having trouble at any point with the Swandive installation, you should review this EC2 setup document.

    Once you have launched an EC2 instance, then do the following:

    1. Go to the EC2 console: https://console.aws.amazon.com/ec2/home

    2. Click Instances, to get a list of all your instances

    3. Click on the instance you just created

    4. Find the `Elastic IP` and `Private IP address`, like the image below:

    ![EC2 example demonstrating where the IP addresses are](https://github.com/iandennismiller/swandive/raw/master/doc/images/ec2_example.png)

0. **Edit `swandive.ini` to set your IP addresses**

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

0. **Install Swandive**

    Swandive is a Xenadu template, which Xenadu must unpack into a system definition.

    ```
    ./swandive.py --template swandive.ini
    mv tmpl_files files && mv files/swandive.py ./swandive.py && chmod 755 ./swandive.py
    ```

    Now our system definition is stored in the dirctory `files`.  The following commands will deploy Swandive to the machine instance.

    ```
    ./swandive.py --apt -v && ./swandive.py --build && ./swandive.py --deploy
    ```

0. **Ensure ipsec will start during boot, then reboot**

    Here, replace $ELASTIC_IP with `public_ip`, from `swandive.ini`.  If you created this instance using the example in ["How to prepare an EC2 machine instance"](https://github.com/iandennismiller/swandive/blob/master/doc/ec2_howto.md), then $ELASTIC_IP is already set for you.

    ```
    ssh root@$ELASTIC_IP "update-rc.d -f ipsec remove; update-rc.d -f ipsec defaults; reboot now"
    ```

0. **Done**

    Swandive is set up, so configure your clients and start using your new VPN!  You can find the authentication (i.e. login) information in `swandive.ini`.  For more information about authentication, read ["Authentication"](https://github.com/iandennismiller/swandive/blob/master/doc/authentication.md).

    To configure an OS X VPN client, read ["Configuring the OS X VPN Client"](https://github.com/iandennismiller/swandive/blob/master/doc/osx_config.md) (which is also useful for configuring an iPod/iPad/iPhone.)

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