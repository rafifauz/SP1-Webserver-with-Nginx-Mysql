#!/bin/bash

echo "Start configuring Web1"
sudo apt update
sudo apt-get install -y nginx php-mysqli mysql-server php-fpm git unzip

1=$(dig +short myip.opendns.com @resolver1.opendns.com)#public IP
sudo mkdir /var/www/web
sudo chown -R $USER:$USER /var/www/web

echo "----------------Setting Nginx---------------"
sudo tee /etc/nginx/sites-available/web1 <<EOL
server {
	listen 81;
	#bisa diganti dengan ip address localhostmu atau ip servermu, nanti kalau sudah ada domain diganti nama domainmu
	server_name \$1;
	#root adalah tempat dmn codingannya di masukkan index.html dll.
	root /var/www/web;
	
	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm ;

	location / {
	    try_files \$uri \$uri/ =404;
	}

	location ~ \.php$ {
	    include snippets/fastcgi-php.conf;
	    fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
	 }

	location ~ /\.ht {
	    deny all;
	}
}
EOL
sudo tee /etc/nginx/sites-available/web2 <<EOL
server {
	listen 82;
	#bisa diganti dengan ip address localhostmu atau ip servermu, nanti kalau sudah ada domain diganti nama domainmu
	server_name \$1;
	#root adalah tempat dmn codingannya di masukkan index.html dll.
	root /var/www/web;
	
	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm ;

	location / {
	    try_files \$uri \$uri/ =404;
	}

	location ~ \.php$ {
	    include snippets/fastcgi-php.conf;
	    fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
	 }

	location ~ /\.ht {
	    deny all;
	}
}
EOL
sudo unlink /etc/nginx/sites-enabled/*
sudo ln -s /etc/nginx/sites-available/web1 /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/web2 /etc/nginx/sites-enabled


echo "----------------Template WEB---------------"

cd /var/www/web/ && sudo git clone https://github.com/rafifauz/SP1-Webserver-with-Nginx-Mysql.git && sudo mv SP1-Webserver-with-Nginx-Mysql/sosial-media-master/* ./ #&& rm ./SP1-Webserver-with-Nginx-Mysql/*.sh

echo "----------------Review & Start Nginx---------------"
sudo nginx -t
#setelah update data harus dicek dengan restart nginx-t dulu sebelum restart nginx
sudo systemctl restart nginx

echo "----------------Membuat User Mysql dan Database---------------"
sudo mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS dbsosmed;
CREATE USER IF NOT EXISTS 'devopscilsy'@'localhost' IDENTIFIED BY '1234567890';
GRANT ALL PRIVILEGES ON * . * TO 'devopscilsy'@'localhost';
FLUSH PRIVILEGES;
EOF
echo "----------------Ambil data dari DUMP.sql---------------"
sudo mysql -u devopscilsy -p dbsosmed < /var/www/web/dump.sql

echo "----Cek apakah server_name sama dengan IP ini ----"
dig +short myip.opendns.com @resolver1.opendns.com
