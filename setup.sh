#!/bin/bash

function install_xenadu() {
    echo "start Xenadu"
    mkdir tmp_xenadu
    cd tmp_xenadu

    echo "downloading Xenadu..."
    curl -s -L https://github.com/iandennismiller/xenadu/tarball/master -o xenadu.tgz
    tar xvfz xenadu.tgz

    echo "switch to Xenadu directory"
    cd iandennismiller-xenadu*

    echo -n "Do you need to use 'sudo' to install python modules (y/n)?"
    read sudo_yes

    if [ "$sudo_yes" == "y" ]; then
        echo "going to run 'sudo python setup.py install'"
        echo "FYI: 'sudo' may prompt you for your password"
        sudo python setup.py install
    fi

    if [ "$sudo_yes" != "y" ]; then
        echo "going to run 'python setup.py install'"
        python setup.py install
    fi

    echo "cleaning up"
    cd ../..
    rm -rf tmp_xenadu
    echo "done"
}

function generate_keys() {
    echo "generating random keys"

    X_MACHINE_KEY=`perl -e '@c=(48..57,65..90,97..122); foreach (1..32) { print chr($c[rand(@c)]) }'`
    sed "s/__MACHINE_KEY__/${X_MACHINE_KEY}/g" swandive.ini > TMPFILE && mv TMPFILE swandive.ini    

    X_USER_KEY=`perl -e '@c=(48..57,65..90,97..122); foreach (1..32) { print chr($c[rand(@c)]) }'`
    sed "s/__USER_KEY__/${X_USER_KEY}/g" swandive.ini > TMPFILE && mv TMPFILE swandive.ini

    sed "s/# IMPORTANT: you need to run setup.sh//g" swandive.ini > TMPFILE && mv TMPFILE swandive.ini

    echo "done"
}

echo -n "Swandive requires Xenadu. Install Xenadu now (y/n)? "
read xenadu_yes
if [ "$xenadu_yes" == "y" ]; then
    install_xenadu
fi

INITIALIZED=`grep __MACHINE_KEY__ swandive.ini`
if [ "$INITIALIZED" != "" ]; then
    generate_keys
fi

echo "Swandive has been initialized."
echo "Please refer to https://github.com/iandennismiller/swandive for next steps."
