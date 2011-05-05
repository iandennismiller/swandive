#!/bin/bash

function install_xenadu() {
    echo "installing Xenadu"
    mkdir tmp_xenadu
    cd tmp_xenadu
    curl -L https://github.com/iandennismiller/xenadu/tarball/master -o xenadu.tgz
    tar xvfz xenadu.tgz
    echo "switch to Xenadu directory"
    cd iandennismiller-xenadu*
    echo "going to run 'sudo python setup.py install'"
    sudo python setup.py install
    cd ..
    rm -rf tmp_xenadu
    echo "done"
}

function generate_keys() {
    X_MACHINE_KEY=`perl -e '@c=(48..57,65..90,97..122); foreach (1..32) { print chr($c[rand(@c)]) }'`
    sed "s/__MACHINE_KEY__/${X_MACHINE_KEY}/g" swandive.ini > TMPFILE && mv TMPFILE swandive.ini    

    X_USER_KEY=`perl -e '@c=(48..57,65..90,97..122); foreach (1..32) { print chr($c[rand(@c)]) }'`
    sed "s/__USER_KEY__/${X_USER_KEY}/g" swandive.ini > TMPFILE && mv TMPFILE swandive.ini

    sed "s/IMPORTANT: you need to run ./setup.sh//g" swandive.ini > TMPFILE && mv TMPFILE swandive.ini
}

#install_xenadu
generate_keys
