# Authentication

0. What is my secret key?

    pre-shared key, secret key, shared secret, password...  these all mean the same thing, in this particular context.  Different VPN clients use slightly different vocabulary, so try to experiment a little bit.

0. Where are the keys?

    The machine key is in `files/ipsec.secrets`, and the user keys are in `files/chap-secrets`.  You can add as many users as you want to chap-secrets.

0. Why are there two keys (user and machine)?

    One key is often called something like "machine key", "system secret", or "machine password", and it is used to make initial contact with the VPN server.  Everyone who contacts this VPN will use the same machine key, in the same way that everyone enters the same password for a wifi access point.  This key is stored in `files/ipsec.secrets`.

    After connecting, the VPN server requires each user to authenticate with a username and password.  This is sometimes called a "user key", "user secret", "user password"...  Each user who connects to the VPN will have their own username and password, which are stored in `files/chap-secrets`.

0. Why use a pre-shared key instead of SSL certificates?

    Using a "pre-shared key" is basically the same as using a password.  Even though SSL certificates would provide better resistance against attack, SSL certificates are not supported by all VPN clients.  As of May 4, 2011 iOS does not support SSL certificates for L2TP/IPsec, and since I want something that would be compatible with the iPhone, there was no choice but to go with pre-shared key.
