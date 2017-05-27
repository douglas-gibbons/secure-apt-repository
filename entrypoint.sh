#!/bin/bash -e

echo "Key-Type: 1
Key-Length: 2048
Subkey-Type: 1
Subkey-Length: 2048
Name-Real: $NAME
Name-Email: $EMAIL
Expire-Date: 0" > gen-key-script

# Do not re-create
[[ -f /root/.gnupg ]] || gpg --batch --gen-key gen-key-script

mkdir -p /packages
mkdir -p /var/www/html/conf

# KEY is the latest GPG key ID
KEY=$(gpg --list-keys 2>/dev/null | grep pub | tail -1 | sed 's/.*\///' | awk '{{print $1}}')

# Export KEY to /var/www/html/keyFile
gpg --output /var/www/html/keyFile --armor --export $KEY

echo "Codename: $CODENAME
Architectures: $ARCHITECTURES
Components: main
SignWith: $KEY" > /var/www/html/conf/distributions

# Add any packages from /packages
/update.sh

# Start Apache
/usr/sbin/apache2ctl -D FOREGROUND

