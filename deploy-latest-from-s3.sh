#!/bin/bash

#*/5 * * * * /srv/www/deploy-latest.sh > /dev/null 2>&1

log () {
    echo "$(date +%Y%m%d_%H%M%S) - $1" | sudo -u www-data tee -a /var/log/application/deploy-$(date +%Y%m%d).log > /dev/null
}

cd /srv/www/;
sudo mv -f latest.txt previous.txt;
S3_BUCKET=jarvis-ui-app/builds
sudo aws s3 cp s3://$S3_BUCKET/latest.txt .;

if [ ! -f latest.txt ]; then
    log "latest.txt not found in $S3_BUCKET !!!";
    exit 1;
fi

LATEST_MD5=$(md5sum latest.txt | cut -d' ' -f1);
PREVIOUS_MD5=$(md5sum previous.txt | cut -d' ' -f1);

if [ $LATEST_MD5 != $PREVIOUS_MD5 ]; then
    DEPLOY_FILE=$(cat latest.txt);
    DEPLOY_FOLDER=$(echo $DEPLOY_FILE | cut -d/ -f1);

    if [ -f $DEPLOY_FOLDER/.env ]; then
        log "$DEPLOY_FOLDER is already DONE!";
        exit 1;
    fi

    sudo aws s3 cp s3://$S3_BUCKET/$DEPLOY_FILE $DEPLOY_FILE;

    if [ ! -f $DEPLOY_FILE ]; then
        log "$DEPLOY_FILE is not found!";
        exit 1;
    fi

    sudo unzip -q $DEPLOY_FILE -d $DEPLOY_FOLDER;
    sudo rm $DEPLOY_FILE;
    sudo chown -R www-data:www-data $DEPLOY_FOLDER;

    if [ ! -f $DEPLOY_FOLDER/.env ]; then
        log "$DEPLOY_FOLDER folder is not complete!";
        exit 1;
    fi

    sudo rm -rf current;
    sudo ln -s $DEPLOY_FOLDER current;
    sudo service php7.0-fpm reload;
    log "$DEPLOY_FOLDER deployed SUCCESSFULLY!";
fi
