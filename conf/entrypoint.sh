#!/usr/bin/env bash

if [ -n $USE_SHARED_WEBROOT ]
then
    if [ $USE_SHARED_WEBROOT == "0" ]
    then
        echo "[IN PROGRESS] Sync Started." > /var/www/magento2/status.html
        sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1status.html/' /home/magento2/magento2/.htaccess
        sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1status.html/' /var/www/magento2/.htaccess
        service apache2 restart
        echo "[IN PROGRESS] Sync Started. Copying started" > /var/www/magento2/status.html
        chown -R magento2:magento2 /home/magento2/magento2
        cp -rf /home/magento2/magento2 /var/www
        if [ -n $CREATE_SYMLINK_EE ]
        then
            if [ $CREATE_SYMLINK_EE == "1" ]
            then
                mkdir -p $HOST_CE_PATH
                ln -s /var/www/magento2/$EE_DIRNAME $HOST_CE_PATH/$EE_DIRNAME
            fi
        fi
        chown -R magento2:magento2 /var/www/magento2
        echo "[IN PROGRESS] Copying Finished" > /var/www/magento2/status.html

        echo "[IN PROGRESS] Unison sync started" > /var/www/magento2/status.html
        su - magento2 -c "unison magento2"

        echo "[DONE] Sync Finished" > /var/www/magento2/status.html
        sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1index.php/' /home/magento2/magento2/.htaccess
        sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1index.php/' /var/www/magento2/.htaccess
        service apache2 restart
        rm -rf /var/www/magento2/status.html
        rm -rf /home/magento2/magento2/status.html
        cat >/etc/supervisor/conf.d/unison.conf <<EOL
[program:unison]
command = /usr/local/bin/unison.sh
redirect_stderr = true
EOL
    fi
fi

supervisord -n -c /etc/supervisord.conf
