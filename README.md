# urbica/postgis

Urbica PostGIS Docker image.

## Features:

- PostGIS
- pgrouting

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

## Extending postgresql.conf

Container will include configs from `/var/lib/postgresql/conf.d` directory.

```shell
docker run \
  -e POSTGRES_PASSWORD=<PASSWORD>
  -v ./db:/var/lib/postgresql/data \
  -v ./postgresql.conf:/var/lib/postgresql/conf.d/postgresql.conf \
  urbica/postgis
```
