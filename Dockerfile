FROM library/debian

# Install the necessary packages
RUN apt update && \
    apt install -y apt-transport-https lsb-release ca-certificates wget && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    apt update && \
    apt install -y php8.2 php8.2-fpm jq nginx cron curl && \
    (crontab -u www-data -l ; echo "* * * * * /app/script/update-dns.sh") | crontab -u www-data -

# Expose port 80
EXPOSE 80

# Start both Nginx and PHP-FPM
CMD service php8.2-fpm start && service cron start && nginx -g "daemon off;"