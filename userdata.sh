#!/bin/bash
yum update -y
yum install -y httpd mod_ssl openssl
systemctl start httpd
systemctl enable httpd
echo "<html><h1>Welcome to My Secure Apache Server</h1></html>" > /var/www/html/index.html
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/selfsigned.key \
  -out /etc/pki/tls/certs/selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

cat <<EOF > /etc/httpd/conf.d/ssl.conf
Listen 443
<VirtualHost *:443>
    DocumentRoot "/var/www/html"
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/selfsigned.crt
    SSLCertificateKeyFile /etc/pki/tls/private/selfsigned.key
</VirtualHost>
EOF
systemctl restart httpd
