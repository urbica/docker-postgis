FROM postgres:10.3
LABEL maintainer="Stepan Kuzmin <to.stepan.kuzmin@gmail.com>"

ENV POSTGIS_VERSION 2.4

RUN set -ex && apt-get update && apt-get install -y --no-install-recommends \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
    postgresql-$PG_MAJOR-pgrouting \
    postgresql-$PG_MAJOR-pgrouting-scripts \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex && mkdir -p /var/lib/postgresql/conf.d && \
    echo "include_dir = '/var/lib/postgresql/conf.d'" >> /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin
