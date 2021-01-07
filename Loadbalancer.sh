#!/bin/bash

#Server1= 54.254.36.186 (Nginx >> LoadBalancer & Webserver )
#Server2= 13.250.7.158 (Nginx >> Webserver)
#Server3= 54.179.243.147	(Mysql >> Database)
sudo apt update
sudo apt-get install -y nginx php-fpm git unzip
var1=$(dig +short myip.opendns.com @resolver1.opendns.com)#public IP
sudo tee /etc/nginx/sites-available/loadBalancer << EOF
upstream loadbalancer {
        server 54.179.243.147:81 weight=3;
        server 54.179.243.147:82;
}

server {
	listen 80;
	#URL pengaksesan (bisa diganti dengan ip address localhostmu atau ip servermu, nanti kalau sudah ada domain diganti nama domainmu)
	server_name $var1;

	location / {
	    proxy_pass http://loadbalancer;
	}
}
EOF
sudo ln -s /etc/nginx/sites-available/loadBalancer /etc/nginx/sites-enabled
echo "----------------Review & Start Nginx---------------"
sudo nginx -t
#setelah update data harus dicek dengan restart nginx-t dulu sebelum restart nginx
sudo systemctl restart nginx
echo "----Cek apakah server_name sama dengan IP ini ----"
dig +short myip.opendns.com @resolver1.opendns.com 
