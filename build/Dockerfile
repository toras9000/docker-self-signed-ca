FROM alpine

ARG CA_COUNTRY=JP
ARG CA_STATE=Tokyo
ARG CA_LOCAL=
ARG CA_ORGANIZATION=
ARG CA_ORGANIUNIT=
ARG CA_COMMONNAME=test-ca.test
ARG CA_DAYS=3650

WORKDIR /work/ca

RUN apk add --no-cache openssl \
 && openssl genrsa -out ca.key 2048 \
 && openssl req \
            -new \
            -x509 \
            -days "${CA_DAYS}" \
            -subj "${CA_COUNTRY:+/C=$CA_COUNTRY}${CA_STATE:+/ST=$CA_STATE}${CA_LOCAL:+/L=$CA_LOCAL}${CA_ORGANIZATION:+/O=$CA_ORGANIZATION}${CA_ORGANIUNIT:+/OU=$CA_ORGANIUNIT}${CA_COMMONNAME:+/CN=$CA_COMMONNAME}" \
            -addext "keyUsage = cRLSign, keyCertSign" \
            -key ca.key \
            -out ca.crt

WORKDIR /work

COPY ./assets/sign.sh  sign.sh

CMD ["sh", "sign.sh"]
