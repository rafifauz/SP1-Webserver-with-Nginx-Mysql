#!/bin/bash

#VM1 54.254.36.186 (Nginx >> LoadBalancer & Webserver )
#VM2 13.250.7.158 (Nginx >> Webserver)
#VM3 54.179.243.147	(Mysql >> Database)
sudo apt update
sudo apt-get install -y nginx php-fpm git unzip
1=$(dig +short myip.opendns.com @resolver1.opendns.com)#public IP
sudo tee /etc/nginx/sites-available/loadBalancer >> EOF
upstream LB {
        server 13.250.7.158:81;
        server 13.250.7.158:82;
}

server {
	listen 80;
	#bisa diganti dengan ip address localhostmu atau ip servermu, nanti kalau sudah ada domain diganti nama domainmu
	server_name \$1;
	#root adalah tempat dmn codingannya di masukkan index.html dll.
	root /var/www/web_baru;
	
	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm ;

	location / {
	    try_files \$uri \$uri/ =404;
	    proxy_pass http://LB;
	}

	location ~ \.php$ {
	    include snippets/fastcgi-php.conf;
	    fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
	 }

	location ~ /\.ht {
	    deny all;
	}
}
EOF
echo "----------------Review & Start Nginx---------------"
sudo nginx -t
#setelah update data harus dicek dengan restart nginx-t dulu sebelum restart nginx
sudo systemctl restart nginx
