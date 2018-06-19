FROM postgres:10.4
LABEL maintainer="Stepan Kuzmin <to.stepan.kuzmin@gmail.com>"

ENV POSTGIS_VERSION 2.4

RUN set -ex && apt-get update && apt-get install -y --no-install-recommends \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_VERSION-scripts \
    postgresql-$PG_MAJOR-pgrouting \
    postgresql-$PG_MAJOR-pgrouting-scripts \
    && rm -rf /var/lib/apt/lists/*

ENV PGCONFD /var/lib/postgresql/conf.d
RUN mkdir -p $PGCONFD && chown -R postgres:postgres $PGCONFD && \
    echo "include_dir = '$PGCONFD'" >> /usr/share/postgresql/postgresql.conf.sample

VOLUME /var/lib/postgresql/conf.d

RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/00-initdb-postgis.sh
COPY ./update-postgis.sh /usr/local/bin

COPY ./initdb-replication.sh /docker-entrypoint-initdb.d/01-initdb-replication.sh