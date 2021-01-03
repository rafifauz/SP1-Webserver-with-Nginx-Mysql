#sudo ssh -i CilsyAWS.pem ubuntu@54.254.112.248

echo "----------------Installasi---------------"
sudo apt update
sudo apt install nginx -y
sudo apt install mysql-server -y
sudo apt install php-fpm -y
sudo apt-get install -y php-mysqli 
sudo apt-get install unzip


1=$(dig +short myip.opendns.com @resolver1.opendns.com)
sudo mkdir /var/www/web_baru
sudo chown -R $USER:$USER /var/www/web_baru

echo "----------------Setting Nginx---------------"
sudo tee /etc/nginx/sites-available/web_baru <<EOL
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
sudo ln -s /etc/nginx/sites-available/web_baru /etc/nginx/sites-enabled
sudo unlink /etc/nginx/sites-enabled/default


echo "----------------Template WEB---------------"

cd /var/www/web_baru && sudo git clone git@github.com:rafifauz/SP1-Webserver-with-Nginx-Mysql.git && sudo mv sosial-media/* ./ && rm Install_Webserver.sh

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

#echo "----------------Membuat User Mysql-Database---------------"
#sudo mysql -u root << EOF
#create user 'devopscilsy'@'localhost' identified by '1234567890';
#grant all privileges on *.* to 'devopscilsy'@'localhost';
#EOF

#echo "----------------Membuat Database Baru ---------------"
#sudo mysql -u devopscilsy -p << EOF
#create database dbsosmed;
#EOF

echo "----------------Ambil data dari DUMP.sql---------------"
sudo mysql -u devopscilsy -p dbsosmed < /var/www/web_baru/dump.sql

echo "----Cek apakah server_name sama dengan IP ini ----"
dig +short myip.opendns.com @resolver1.opendns.com


#cek php server
#ps ax | grep "php"
#tail -f /var/log/nginx/error.log
#https://github.com/sdcilsy/sosial-media/archive/master.zip


