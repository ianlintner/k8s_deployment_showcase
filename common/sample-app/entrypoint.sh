#!/bin/sh

# Replace environment variables in HTML
envsubst '${APP_VERSION} ${APP_COLOR} ${HOSTNAME}' < /usr/share/nginx/html/index.html > /tmp/index.html
mv /tmp/index.html /usr/share/nginx/html/index.html

# Replace environment variables in nginx config for API endpoint
sed -i "s/\$APP_VERSION/$APP_VERSION/g" /etc/nginx/conf.d/default.conf
sed -i "s/\$APP_COLOR/$APP_COLOR/g" /etc/nginx/conf.d/default.conf

# Execute the CMD
exec "$@"
