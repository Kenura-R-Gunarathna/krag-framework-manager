#!/bin/bash

source ./includes/colors.sh
source ./includes/functions.sh

echo -e "
${BLUE}--------------------------------------------
${BLUE}            KRAG Site Creator
${GREBLUEEN}--------------------------------------------${NC}
"

read -p "Site Name (With the domain): " sitename
echo

selections=(
"laravel"
"karch"
"custom"
)

choose_from_menu "Select the framework:" selected_choice "${selections[@]}";

output_folder=""

echo
case $selected_choice in
"laravel")
  
    composer create-project laravel/laravel /var/www/$sitename
    output_folder="public"
    ;;
"karch")

    composer create-project krag/karch /var/www/$sitename
    output_folder="public"
    ;;
"custom")

    mkdir /var/www/$sitename

    echo -e "
    <html>
    <head>
        <title>$sitename website</title>
    </head>
    <body>
        <h1>Hello World!</h1>

        <p>This is the landing page of <strong>$sitename</strong>.</p>
    </body>
    </html>
    " > /var/www/$sitename/index.html
    ;;
*)
  echo "Invalid input!"
  exit;;
esac

sudo echo -e "
define ROOT "/var/www/$sitename/$output_folder"
define SITE "$sitename"

<VirtualHost *:80>
    DocumentRoot \"\${ROOT}\"

    ServerName \${SITE}
    ServerAlias *.\${SITE}

    <Directory \"\${ROOT}\">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$sitename.conf

sudo a2ensite $sitename

sudo apache2ctl configtest

sudo echo "127.0.0.1	$sitename" >> /etc/hosts

sudo systemctl reload apache2

sudo chmod -R ugo+rw /var/www/$sitename/
