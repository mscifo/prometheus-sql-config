#!/bin/sh

CONFIG_DIR=${CONFIG_DIR:=/etc/prometheus-sql-config}

if [[ -z $TOKEN && -n $TOKEN_FILE ]]; then
    TOKEN=$(cat $TOKEN_FILE)
fi

if [ -z $TOKEN ]; then
    echo TOKEN or TOKEN_FILE environment variable must be provided
    exit 0
fi

if [ -z $GIT_URL ]; then
    echo GIT_URL environment variable must be provided
    exit 0
fi

restart_prometheus_sql()
{
    if [ -z $PROMSQL_IMAGE_NAME ]; then
        echo Image name for prometheus-sql not specified, cannot restart prometheus-sql
        return
    fi

    if ! type "docker" > /dev/null; then
        echo Docker not available, cannot restart prometheus-sql
        return
    fi

    if [ ! -S "/var/run/docker.sock" ]; then
        echo Docker volume not mounted, cannot restart prometheus-sql
        return
    fi

    CONTAINER_ID=$(docker ps | grep "$PROMSQL_IMAGE_NAME" | cut -d ' ' -f1)

    if [ -z $CONTAINER_ID ]; then
        echo Could not find prometheus-sql container with image $PROMSQL_IMAGE_NAME, cannot restart prometheus-sql
        return
    fi

    echo Restarting prometheus-sql at container ID: $CONTAINER_ID
    docker kill --signal "SIGHUP" $CONTAINER_ID
    echo Restart signal sent
}

while true; do 
    if [ -d "$CONFIG_DIR/.git" ]; then
        echo Checking for updated config
        cd $CONFIG_DIR

        if ! git pull origin master | grep -q "Already up-to-date."; then
            echo Retrieved updated config
            restart_prometheus_sql
        fi
    else
        echo Retrieving config for the first time into $CONFIG_DIR
        git clone https://$TOKEN@$GIT_URL $CONFIG_DIR
        restart_prometheus_sql
    fi

    sleep 30
done

