#!/bin/bash
# 2023-08-31 Robert Sturzbecher
# This script fixes the issue of Debian Jessie giving a SSL expired error caused by not having the CA cert installed.
# But you know the correct fix is really to upgrade from Jessie ;)

if [[ ! -f "/usr/share/ca-certificates/mozilla/ISRG_Root_X1.crt" ]]; then
    echo CA Cert missing, installing...
    curl -o /usr/share/ca-certificates/mozilla/ISRG_Root_X1.crt https://letsencrypt.org/certs/isrgrootx1.pem -k
    sed -i 's/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g' /etc/ca-certificates.conf
    echo "mozilla/ISRG_Root_X1.crt" | tee -a /etc/ca-certificates.conf
    update-ca-certificates
else
    echo CA cert already present, no changes made.
fi
