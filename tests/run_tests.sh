#!/bin/sh -e
#
# Copyright (c) 2025
# Embetrix Embedded Systems Solutions, ayoub.zaki@embetrix.com
#

echo "Running pycrypto-helper tests..."
export PKCS11_MODULE_PATH=/usr/lib/softhsm/libsofthsm2.so
export PIN="12345"
export SO_PIN="1234"
export SOFTHSM2_CONF=$PWD/.softhsm/softhsm2.conf
export TOKEN_NAME="token0"

rm -rf .softhsm
mkdir -p .softhsm/tokens
echo "directories.tokendir = $PWD/.softhsm/tokens" > .softhsm/softhsm2.conf
pkcs11-tool --pin $PIN --module $PKCS11_MODULE_PATH --slot-index=0 --init-token --label=$TOKEN_NAME --so-pin $SO_PIN --init-pin 
pkcs11-tool --pin $PIN --module $PKCS11_MODULE_PATH --keypairgen --key-type EC:prime256v1 --id 62 --label "testkeyECp256"
pkcs11-tool --pin $PIN --module $PKCS11_MODULE_PATH --keypairgen --key-type RSA:2048      --id 66 --label "testkeyRSA2048"
pkcs11-tool --pin $PIN --module $PKCS11_MODULE_PATH --keygen     --key-type aes:32        --id 68 --label "testkeyAES256"

#p11tool --list-all --login --provider=$PKCS11_MODULE_PATH --set-pin=$PIN

openssl genpkey -algorithm RSA -out rsa_key.pem -pkeyopt rsa_keygen_bits:2048 -aes256 -pass pass:pa33w0rd  > /dev/null 2>&1
openssl rsa -pubout -in rsa_key.pem -out rsa_pubkey.pem -passin pass:pa33w0rd  > /dev/null 2>&1
openssl req -new -x509 -key rsa_key.pem -passin pass:pa33w0rd -out rsa_cert.pem -days 365 -subj "/O=Embetrix/CN=HSM-Test/emailAddress=info@embetrix.com"  > /dev/null 2>&1

openssl req -new -x509 -engine pkcs11 -keyform engine -key "pkcs11:object=testkeyECp256?pin-value=12345"  -out testcertECp256.pem -days 365 -subj "/O=Embetrix/CN=HSM-Test/emailAddress=info@embetrix.com"
openssl req -new -x509 -engine pkcs11 -keyform engine -key "pkcs11:object=testkeyRSA2048?pin-value=12345" -out testcertRSA2048.pem -days 365 -subj "/O=Embetrix/CN=HSM-Test/emailAddress=info@embetrix.com"

openssl ecparam -name prime256v1 -genkey -noout -out ecdsa_key.pem  > /dev/null 2>&1
openssl ec -in ecdsa_key.pem -pubout -out ecdsa_pubkey.pem  > /dev/null 2>&1
openssl req -new -x509 -key ecdsa_key.pem -out ecdsa_cert.pem -days 365 -subj "/O=Embetrix/CN=HSM-Test/emailAddress=info@embetrix.com"  > /dev/null 2>&1

 dd if=/dev/urandom of=aes.key bs=1 count=32 > /dev/null 2>&1
 

python tests/test_pycrypto_helper.py
