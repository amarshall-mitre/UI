#!/bin/sh
sed -in 's/#LoadModule proxy_module/LoadModule proxy_module/' /etc/httpd/conf/httpd.conf
sed -in 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/' /etc/httpd/conf/httpd.conf
sed -in 's/#LoadModule ssl_module/LoadModule ssl_module/g' /etc/httpd/conf/httpd.conf

sed -in '/<Directory "\/usr\/local\/apache2\/htdocs">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -in 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf/httpd.conf

echo "SSLProxyEngine on" >> /etc/httpd/conf/httpd.conf
echo "ProxyPass /api $API_URL/api retry=0" >> /etc/httpd/conf/httpd.conf
echo "ProxyPass /apiaudit $API_URL/apiaudit retry=0" >> /etc/httpd/conf/httpd.conf

httpd -DFOREGROUND

