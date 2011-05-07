# How to prepare an EC2 machine instance for Swandive

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
