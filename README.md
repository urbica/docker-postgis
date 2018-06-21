# urbica/postgis

Urbica PostGIS Docker image.
Based on official [postgres:10](https://hub.docker.com/_/postgres/) image.

## Features:

- [PostGIS](https://postgis.net/) with topology
- [pgRouting](https://pgrouting.org/)
- [MySQL Foreign Data Wrapper](https://github.com/EnterpriseDB/mysql_fdw)
- [Configuration managment](https://www.postgresql.org/docs/10/static/config-setting.html#CONFIG-INCLUDES)
- [Streaming Replication](https://www.postgresql.org/docs/10/static/warm-standby.html#STREAMING-REPLICATION)

## Environment variables

| Variable                      | Description                                |
| ----------------------------- | ------------------------------------------ |
| POSTGRES_DB                   | Database name                              |
| POSTGRES_USER                 | Database user name                         |
| POSTGRES_PASSWORD             | Database user password                     |
| POSTGRES_REPLICATION_MODE     | Database replication mode `master`/`slave` |
| POSTGRES_REPLICATION_USER     | Database replication user name             |
| POSTGRES_REPLICATION_PASSWORD | Database replication user password         |
| POSTGRES_MASTER_HOST          | Database replication master host           |
| POSTGRES_MASTER_PORT          | Database replication master port           |

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

## Streaming Replication

A Streaming replication cluster can be setup with using the following environment variables:

- `POSTGRES_REPLICATION_MODE`: Replication mode. Can be `master` or `slave`.
- `POSTGRES_REPLICATION_USER`: The replication user created on the `master` on first run.
- `POSTGRES_REPLICATION_PASSWORD`: The replication users password.
- `POSTGRES_MASTER_HOST`: Hostname/IP of replication `master` (`slave` parameter).
- `POSTGRES_MASTER_PORT`: Server port of the replication `master` (`slave` parameter).

### Step 1: Create the replication master

```shell
docker run --name db_master \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=user_password \
  -e POSTGRES_REPLICATION_MODE=master \
  -e POSTGRES_REPLICATION_USER=replicate \
  -e POSTGRESQL_REPLICATION_PASSWORD=replicate_password \
  urbica/postgis
```

### Step 2: Create the replication slave

```shell
docker run --name db_slave \
  --link db_master \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=user_password \
  -e POSTGRES_REPLICATION_MODE=slave \
  -e POSTGRES_REPLICATION_USER=replicate \
  -e POSTGRESQL_REPLICATION_PASSWORD=replicate_password \
  urbica/postgis
```

You can also setup replication using [docker-compose.yml](https://github.com/urbica/docker-postgis/blob/debian/docker-compose.yml).
