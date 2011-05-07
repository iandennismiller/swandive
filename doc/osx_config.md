# Configuring the OS X VPN client

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

    ![VPN configuration - create VPN interface](https://github.com/iandennismiller/swandive/raw/master/doc/images/osx vpn config - create vpn interface.png)

0. Configure Swandive VPN Server Address and Account Name

    Now look at `swandive.ini` and copy the `public_ip` into "Server Address." The "Account Name" is the `user_name`.  

    ![VPN configuration - server address and account](https://github.com/iandennismiller/swandive/raw/master/doc/images/osx vpn config - server address and account.png)

0. Click "Authentication Settings"

    0. Under User Authentication, click "Password" and copy the `user_key` into this field.

    0. Under Machine Authentication, click "Shared Secret" and copy `machine_key` into this field.

    ![VPN configuration - passwords](https://github.com/iandennismiller/swandive/raw/master/doc/images/osx vpn config - user password and machine secret.png)

0. Click "Advanced" and enable "send all traffic over VPN connection"

    This critical step will make sure to encrypt all of the traffic coming out of your machine.  If you forget this step, then the VPN actually won't do anything useful for you at all!

    ![VPN configuration - passwords](https://github.com/iandennismiller/swandive/raw/master/doc/images/osx vpn config - send all traffic.png)

0. Connect

    You're done.  Shortly after you click connect, your machine will be given a new IP address like `192.168.79.2`.  If you visit http://whatsmyip.org you should see that your IP address is now reported to be the same as your Swandive `public_ip`.  Success!
