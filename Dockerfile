FROM postgres:10.4
LABEL maintainer="Stepan Kuzmin <to.stepan.kuzmin@gmail.com>"

RUN set -ex && apt-get update -q && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    docbook-mathml \
    docbook-xsl \
    git \
    libgdal-dev \
    libgeos-dev \
    libjson-c-dev \
    libproj-dev \
    libprotobuf-c-dev \
    libtool \
    libxml2-dev \
    postgresql-server-dev-10 \
    protobuf-c-compiler \
    xsltproc \
    && rm -rf /var/lib/apt/lists/*

# Install GDAL
# ENV GDAL_VERSION 2.3.1
# RUN set -ex \
#     && curl -O http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz \
#     && tar xvzf gdal-$GDAL_VERSION.tar.gz \
#     && cd gdal-$GDAL_VERSION \
#     && ./configure \
#     && make \
#     && make install \
#     && cd .. \
#     && rm -rf gdal-$GDAL_VERSION*

# Install GEOS
# ENV GEOS_VERSION 3.7.0beta1
# RUN set -ex \
#     && curl -O http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2 \
#     && tar xvjf geos-$GEOS_VERSION.tar.bz2 \
#     && cd geos-$GEOS_VERSION \
#     && ./configure \
#     && make \
#     && make install \
#     && cd .. \
#     && rm -rf geos-$GEOS_VERSION*

# Install PostGIS from mvt-feature-id fork
RUN set -ex \
    && git clone -b mvt-feature-id https://github.com/stepankuzmin/postgis.git \
    && cd postgis \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd extensions/postgis \
    && make clean \
    && make \
    && make install \
    && cd .. \
    && rm -rf postgis

ENV PGCONFD /var/lib/postgresql/conf.d
VOLUME /var/lib/postgresql/conf.d

RUN mkdir -p $PGCONFD && chown -R postgres:postgres $PGCONFD && \
    echo "include_dir = '$PGCONFD'" >> /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/00-initdb-postgis.sh
COPY ./update-postgis.sh /usr/local/bin