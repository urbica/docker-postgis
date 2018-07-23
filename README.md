# urbica/postgis

Urbica PostGIS Docker image.
Based on official [postgres:10](https://hub.docker.com/_/postgres/) image.

## Features:

- [PostGIS](https://postgis.net/)
- [Configuration managment](https://www.postgresql.org/docs/10/static/config-setting.html#CONFIG-INCLUDES)

## Environment variables

| Variable          | Description            |
| ----------------- | ---------------------- |
| POSTGRES_DB       | Database name          |
| POSTGRES_USER     | Database user name     |
| POSTGRES_PASSWORD | Database user password |

## Usage

```shell
docker run -d -e POSTGRES_PASSWORD= urbica/postgis
```

## Extending configuration

Container will [include](https://www.postgresql.org/docs/10/static/config-setting.html#CONFIG-INCLUDES) configs from `/var/lib/postgresql/conf.d` directory.

```shell
docker run \
  -e POSTGRES_PASSWORD=<PASSWORD>
  -v ./db:/var/lib/postgresql/data \
  -v ./shared.conf:/var/lib/postgresql/conf.d/shared.conf \
  urbica/postgis
```
