#!/bin/sh

set -e

SIGN_COUNTRY=${SIGN_COUNTRY:-JP}
SIGN_STATE=${SIGN_STATE}
SIGN_LOCAL=${SIGN_LOCAL}
SIGN_ORGANIZATION=${SIGN_ORGANIZATION}
SIGN_ORGANIUNIT=${SIGN_ORGANIUNIT}
SIGN_CMNNAME=${SIGN_CMNNAME}
SIGN_EXT_ALTNAME=${SIGN_EXT_ALTNAME:-${SIGN_CMNNAME:+DNS:$SIGN_CMNNAME}}
SIGN_DAYS=${SIGN_DAYS:-3650}
SIGN_SERIAL=${SIGN_SERIAL}

mkdir -p /work/signed
cd /work/signed

openssl genrsa -out server.key 2048

openssl req \
        -new \
        -subj "${SIGN_COUNTRY:+/C=$SIGN_COUNTRY}${SIGN_STATE:+/ST=$SIGN_STATE}${SIGN_LOCAL:+/L=$SIGN_LOCAL}${SIGN_ORGANIZATION:+/O=$SIGN_ORGANIZATION}${SIGN_ORGANIUNIT:+/OU=$SIGN_ORGANIUNIT}${SIGN_CMNNAME:+/CN=$SIGN_CMNNAME}" \
        -addext "${SIGN_EXT_ALTNAME:+subjectAltName = $SIGN_EXT_ALTNAME}" \
        -key server.key \
        -out server.csr

mkdir -p /work/tmp
echo "basicConstraints=CA:FALSE"                                > /work/tmp/ext.txt
echo "subjectKeyIdentifier=hash"                               >> /work/tmp/ext.txt
echo "authorityKeyIdentifier=keyid,issuer"                     >> /work/tmp/ext.txt
echo "${SIGN_EXT_ALTNAME:+subjectAltName = $SIGN_EXT_ALTNAME}" >> /work/tmp/ext.txt

SERIAL_OPT=${SIGN_SERIAL:+set_serial $SIGN_SERIAL}
SERIAL_OPT=${SERIAL_OPT:--CAcreateserial}

openssl x509 \
        -req \
        -days "${SIGN_DAYS}" \
        -extfile /work/tmp/ext.txt \
        -CA    /work/ca/ca.crt \
        -CAkey /work/ca/ca.key \
        ${SERIAL_OPT} \
        -in server.csr \
        -out server.crt


cp /work/ca/ca.crt /work/signed/

if [ "$SHOW_CERT" = "TRUE" ]; then
    openssl x509 -text -noout -in /work/signed/server.crt
fi

if [ "$COPY_CA_KEY" = "TRUE" ]; then
    cp /work/ca/ca.key /work/signed/
fi