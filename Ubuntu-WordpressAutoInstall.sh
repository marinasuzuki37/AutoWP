#!/bin/bash

####
# Wordpress Auto Installer on Ubuntu Script (Japanese)
# Copyright (c) 2023 Marina Suzuki
# This software is released under the MIT license
# https://opensource.org/licenses/mit-license.php
###

echo "Wordpress自動インストールスクリプトへようこそ"
echo "このスクリプトは質問に「全て」お答え頂くことでWordpress、Apache2、MySQL、PHPの自動インストールを行います"
echo ""
#必要情報の収集
read -p "あなたのサイトのドメイン名を入力してください: " domain_name
read -p "Wordpressで使うデータベースの名前を決めてください:" db_name
read -p "データベースのユーザー名を決めてください（Wordpressのユーザー名とは違います。）: " db_user
read -sp "データーベースのパスワードを決めてください: " db_pass
echo ""
read -p "Wordpresssで構築するサイトの名前を決めてください: " site_name
read -p "Wordpressの管理者ユーザー名を決めてください: " admin_user
read -sp "Wordpress管理者ユーザーのパスワードを決めてください: " admin_pass
echo ""
read -p "管理者ユーザーで使うあなたのEメールアドレスを入力してください: " admin_email
echo ""
read -p "サイトをSSL暗号通信化しますか? (y/n): " enable_ssl
echo ""
＃
#収集した情報の確認表示とインストール実行確認と設定情報の記録
touch wordpress_settings.log
echo "以下の情報でインストールされます"
echo ""
echo "wordpressの設定情報" >> wordpress_settings.log
echo "ドメイン名: $domain_name " | tee -a wordpress_settings.log
echo "データベース名: $db_name " | tee -a wordpress_settings.log
echo "データベースのユーザー名: $db_user " | tee -a wordpress_settings.log
echo "データベースのパスワード: $db_pass " | tee -a wordpress_settings.log
echo "Wordpressのユーザー名: $admin_user " | tee -a wordpress_settings.log
echo "Wordpressのパスワード: $admin_pass " | tee -a wordpress_settings.log
echo "あなたのEメールアドレス: $admin_email " | tee -a wordpress_settings.log
echo ""

#実行確認分岐
echo "本当に実行してよろしいですか(y/n)"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then

#処理中表示
echo "処理中..."
sleep 2

# Apache2のインストール
sudo apt update
sudo apt install -y apache2

# Apache2バーチャルホストの設定
sudo mkdir -p /var/www/$domain_name/html
sudo chown -R www-data:www-data /var/www/$domain_name/html
sudo chmod -R 755 /var/www/$domain_name
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$domain_name.conf
sudo sed -i "s|/var/www/html|/var/www/$domain_name/html|g" /etc/apache2/sites-available/$domain_name.conf
sudo sed -i "s|ServerAdmin webmaster@localhost|ServerAdmin admin@$domain_name|g" /etc/apache2/sites-available/$domain_name.conf
sudo sed -i "s|ServerName localhost|ServerName $domain_name|g" /etc/apache2/sites-available/$domain_name.conf
sudo sed -i "s|ServerAlias _|ServerAlias www.$domain_name|g" /etc/apache2/sites-available/$domain_name.conf

# バーチャルホストの有効化
sudo a2ensite $domain_name.conf

# デフォルトの Apache2サイト構成が存在する場合は無効化
if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
  sudo a2dissite 000-default.conf
fi

if [ "$enable_ssl" = "y" ]; then
    #  Let's Encrypt Certbotのインストール
    sudo apt-get install -y python3-certbot-apache certbot

    # SSL証明書の取得
    sudo certbot --apache -d "$domain_name" -d "www.$domain_name" -m admin@"$domain_name" --agree-tos --non-interactive
    
    #Apache2にSSL化設定
    sudo touch /etc/apache2/sites-available/$domain_name-ssl.conf 
    sudo tee /etc/apache2/sites-available/$domain_name-ssl.conf > /dev/null <<EOF
<IfModule mod_ssl.c>
  <VirtualHost *:443>
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
      <Directory /var/www/$domain_name/html>
        AllowOverride All
      </Directory>
    SSLCertificateFile /etc/letsencrypt/live/$domain_name/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$domain_name/privkey.pem
    include /etc/letsencrypt/options-ssl-apache.conf
  </VirtualHost>
</IfModule>
EOF
fi

# Apache2設定情報のチェック
sudo apache2ctl configtest
sudo systemctl restart apache2

# MySQLとPHPとsendmailのインストール
sudo apt install -y mysql-server php libapache2-mod-php php-mysql php-zip php-curl php-gd php-xml php-mbstring

# MySQLの設定
sudo mysql -e "CREATE USER $db_user@localhost IDENTIFIED BY '$db_pass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO $db_user@localhost;"
sudo mysql -e "FLUSH PRIVILEGES;"

#WP-CLIのインストール
cd /tmp
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Wordpressのインストール設定
cd /var/www/
sudo mkdir -p /var/www/.wp-cli/cache/
sudo chown www-data:www-data /var/www/.wp-cli/cache/
cd /var/www/$domain_name/html
sudo -u www-data wp core download --locale=ja
sudo -u www-data wp config create --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --dbhost=localhost --extra-php <<PHP
define('WP_DEBUG', false);
PHP
sudo -u www-data wp db create
sudo -u www-data wp core install --url=$domain_name --title="$site_name" --admin_user=$admin_user --admin_password=$admin_pass --admin_email=$admin_email

echo "Wordpressのインストールが全て完了しました!"
echo "以下のURLであなたのWordpressサイトにアクセスできます!"

#SSL有効無効で表示分岐
if [ "$enable_ssl" = "y" ]; then
  echo "https://$domain_name"
else
  echo "http://$domain_name"
fi

else
  echo "実行を中止しました。"
  sleep 2
  exit 1
fi
exit 0
