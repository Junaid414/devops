# Use official Apache HTTP server image
FROM httpd:2.4

# Copy your HTML file into Apache's default web directory
COPY sample_index.html /usr/local/apache2/htdocs/index.html

# Expose HTTP port
EXPOSE 80

# Start Apache
CMD ["httpd-foreground"]
