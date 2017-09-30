# Prometheus SQL Config Store Dockerfile

## Description
This container is designed to operate as a data container, or 'sidekick' to [prometheus-sql](https://github.com/chop-dbhi/prometheus-sql). 

It will periodically pull [prometheus-sql](https://github.com/chop-dbhi/prometheus-sql) configuration from the specified git repository and restart the [prometheus-sql](https://hub.docker.com/r/dbhi/prometheus-sql/) docker container if changes are found.

## Usage
Below is the docker compose syntax to run this container, the expectation being this is mapped in using `volumes_from` and sidekicks.  Keep in-mind this is designed around an implementation within a Rancher managed environment.

```
prometheus-sql-config:
    tty: true
    image: mscifo/prometheus-sql-config:latest
    environment:
      GIT_URL: URL of git repository containing prometheus-sql config files. Ex: github.com/ORG/REPO. (required, without http/https)
      TOKEN: GitHub Token or user:pass. (required unless TOKEN_FILE specified)
      TOKEN_FILE: File inside containing Github token or user:pass inside container. (required unless TOKEN specified) 
      CONFIG_DIR: Directory to store cloned git repository. Default is /etc/prometheus-sql-config. (optional)
      PROMSQL_IMAGE_NAME: Image name of prometheus-sql. Default is dbhi/prometheus-sql. (optional) 
    volumes:
      - /etc/prometheus-sql-config  # Change to match CONFIG_DIR
```

## Further Info
The `prometheus-sql-config` container can be found on the docker hub [here](https://hub.docker.com/r/mscifo/prometheus-sql-config/)