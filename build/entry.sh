#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

# Config checks
[ -z "$MAILMAN_URLHOST" ] && echo "Error: MAILMAN_URLHOST not set" && exit 128 || true
[ -z "$MAILMAN_EMAILHOST" ] && echo "Error: MAILMAN_EMAILHOST not set" && exit 128 || true
[ -z "$MAILMAN_ADMINMAIL" ] && echo "Error: MAILMAN_ADMINMAIL not set" && exit 128 || true
[ -z "$MAILMAN_ADMINPASS" ] && echo "Error: MAILMAN_ADMINPASS not set" && exit 128 || true
[ -z "$MAILMAN_LANGUAGE" ] && echo "Error: MAILMAN_LANGUAGE not set" && exit 128 || true

# Copy default mailman etc from cache
if [ ! "$(ls -A /etc/mailman)" ]; then
   cp -a /etc/mailman.cache/. /etc/mailman/
fi

# Copy default mailman data from cache
if [ ! "$(ls -A /var/lib/mailman)" ]; then
   cp -a /var/lib/mailman.cache/. /var/lib/mailman/
fi

# Copy default spool from cache
if [ ! "$(ls -A /var/spool/postfix)" ]; then
   cp -a /var/spool/postfix.cache/. /var/spool/postfix/
fi

# Fix permissions
/usr/lib/mailman/bin/check_perms -f

# If master list does not exist, create it
if [ ! -d /var/lib/mailman/lists/mailman ]; then
    /var/lib/mailman/bin/newlist --quiet --urlhost=$MAILMAN_URLHOST --emailhost=$MAILMAN_EMAILHOST mailman $MAILMAN_ADMINMAIL $MAILMAN_ADMINPASS
fi

# Set mailman admin password
mmsitepass $MAILMAN_ADMINPASS

sed -i -e "s@^DEFAULT_EMAIL_HOST.*@DEFAULT_EMAIL_HOST = \'${MAILMAN_EMAILHOST}\'@g" /etc/mailman/mm_cfg.py
sed -i -e "s@^DEFAULT_URL_HOST.*@DEFAULT_URL_HOST = \'${MAILMAN_EMAILHOST}\'@g" /etc/mailman/mm_cfg.py
sed -i -e "s@^DEFAULT_SERVER_LANGUAGE.*@DEFAULT_SERVER_LANGUAGE = \'${MAILMAN_LANGUAGE}\'@g" /etc/mailman/mm_cfg.py

# Fix Postfix settings
postconf -e mydestination=${MAILMAN_EMAILHOST}
postconf -e myhostname=${HOSTNAME}
postconf -e "alias_maps = hash:/etc/aliases hash:/etc/aliases.mailman"
postconf -e "alias_database = hash:/etc/aliases hash:/etc/aliases.mailman"

# 20MB size limit
postconf -e mailbox_size_limit=20971520

if [ -n "$MAILMAN_SSL_CRT" ] && [ -n "$MAILMAN_SSL_KEY" ] && [ -n "$MAILMAN_SSL_CA" ]; then
    postconf -e smtpd_use_tls=yes
    postconf -e smtpd_tls_cert_file=${MAILMAN_SSL_CRT}
    postconf -e smtpd_tls_key_file=${MAILMAN_SSL_KEY}
    postconf -e smtpd_tls_CAfile=${MAILMAN_SSL_CA}
fi

# Init Postfix Config
#/usr/lib/mailman/bin/genaliases -q >> /etc/aliases
/usr/lib/mailman/bin/genaliases -q > /etc/aliases.mailman
newaliases

exec $@
