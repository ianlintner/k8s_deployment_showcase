FROM nginx:1.25-alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy HTML content
COPY index.html /usr/share/nginx/html/index.html

# Environment variables for versioning
ENV APP_VERSION="1.0.0"
ENV APP_COLOR="blue"

# Create a script to inject environment variables into HTML
RUN apk add --no-cache gettext

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
