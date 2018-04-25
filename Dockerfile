FROM postgres:10.3-alpine
MAINTAINER Nick Lebedev <nextstopsun@gmail.com>

RUN set -ex \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        g++ \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        perl \
        cmake \
        xz

RUN set -ex \
    && apk add --no-cache --virtual .build-deps-testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        gdal-dev \
        geos-dev \
        proj4-dev

# Install CGAL

RUN set -ex \
    && apk add --no-cache --virtual .cgal-build-deps \
        boost \
        boost-dev \
        gmp \
        gmp-dev\
        mpfr-dev

ENV CGAL_VERSION 4.11.1
ENV CGAL_SHA256 fb152fc30f007e5911922913f8dc38e0bb969b534373ca0fbe85b4d872300e8b

RUN set -ex \
    && wget -O cgal.tar.xz https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-$CGAL_VERSION/CGAL-$CGAL_VERSION.tar.xz \
    && echo "$CGAL_SHA256 *cgal.tar.xz" | sha256sum -c - \
    && mkdir -p /usr/src/cgal \
    && tar \
        --extract \
        --file cgal.tar.xz \
        --directory /usr/src/cgal \
        --strip-components 1 \
    && rm cgal.tar.xz

RUN set -ex \
    && cd /usr/src/cgal \
    && cmake -DCMAKE_INSTALL_LIBDIR='/usr/local/lib' . \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/cgal

# Install SFCGAL

RUN set -ex \
    && apk add --no-cache --virtual .sfcgal-build-deps \
        boost \
        boost-dev

ENV SFCGAL_VERSION 1.3.2
ENV SFCGAL_SHA256 1ae0ce1c38c728b5c98adcf490135b32ab646cf5c023653fb5394f43a34f808a

RUN set -ex \
    && wget -O sfcgal.tar.gz "https://github.com/Oslandia/SFCGAL/archive/v$SFCGAL_VERSION.tar.gz" \
    && echo "$SFCGAL_SHA256 *sfcgal.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/sfcgal \
    && tar \
        --extract \
        --file sfcgal.tar.gz \
        --directory /usr/src/sfcgal \
        --strip-components 1 \
    && rm sfcgal.tar.gz

RUN set -ex \
    && cd /usr/src/sfcgal \
    && cmake -DCMAKE_INSTALL_LIBDIR='/usr/local/lib' . \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/sfcgal

# Install PostGIS

RUN set -ex \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
        protobuf-c-dev

RUN set -ex \
    && apk add --no-cache --virtual .postgis-rundeps-testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \
        proj4 \
        protobuf-c

ENV POSTGIS_VERSION 2.4.3
ENV POSTGIS_SHA256 b9754c7b9cbc30190177ec34b570717b2b9b88ed271d18e3af68eca3632d1d95

RUN set -ex \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/$POSTGIS_VERSION.tar.gz" \
    && echo "$POSTGIS_SHA256 *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz

RUN set -ex \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/postgis

# PG Routing

ENV PGROUTING_VERSION 2.6.0

RUN set -ex \
    && wget -O pgrouting.tar.gz "https://github.com/pgRouting/pgrouting/releases/download/v$PGROUTING_VERSION/pgrouting-$PGROUTING_VERSION.tar.gz" \
    && mkdir -p /usr/src/pgrouting \
    && tar \
        --extract \
        --file pgrouting.tar.gz \
        --directory /usr/src/pgrouting \
        --strip-components 1 \
    && rm pgrouting.tar.gz

RUN set -ex \
    && cd /usr/src/pgrouting \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/postgis

# Cleanup

RUN set -ex \
    && apk del .fetch-deps .build-deps .build-deps-testing .cgal-build-deps .sfcgal-build-deps

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin
