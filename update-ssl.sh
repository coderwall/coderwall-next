#!/usr/bin/env bash
set -e
FILE=/tmp/coderwall-certs.txt

extract_cert() {
  sed -n "/$1/,/END CERTIFICATE/p" $FILE | tail -n +2
}

heroku run rake letsencrypt_plugin > $FILE
extract_cert coderwall.com-cert.pem > /tmp/coderwall.com-cert.pem
extract_cert coderwall.com-key.pem > /tmp/coderwall.com-key.pem
heroku certs:update /tmp/coderwall.com-cert.pem /tmp/coderwall.com-key.pem --confirm coderwall-next
