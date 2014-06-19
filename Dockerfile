# VERSION 0.1
# AUTHOR:         Olav Grønås Gjerde <olav@backupbay.com>
# DESCRIPTION:    Image with moinmoin wiki, uwsgi, nginx and self signed SSL
# TO_BUILD:       docker build -rm -t moinmoin .
# TO_RUN:         docker run --rm -p [80:80,443:443] moinmoin

FROM ubuntu:trusty
MAINTAINER Olav Grønås Gjerde <olav@backupbay.com>

# Set the version you want of MoinMoin
ENV MM_VERSION 1.9.7
ENV MM_CSUM 38b7783abb8530253545d780c8019721

# Update
RUN apt-get update
RUN apt-get -y upgrade

# Install software
RUN apt-get -y install python-pip wget nginx uwsgi uwsgi-plugin-python

# Download MoinMoin
RUN wget \
  https://bitbucket.org/thomaswaldmann/moin-1.9/get/$MM_VERSION.tar.gz
RUN if [ "$MM_CSUM" != "$(md5sum $MM_VERSION.tar.gz | awk '{print($1)}')" ];\
  then exit 1; fi;
RUN mkdir moinmoin
RUN tar xf $MM_VERSION.tar.gz -C moinmoin --strip-components=1
RUN rm $MM_VERSION.tar.gz

# Install MoinMoin
RUN cd moinmoin && python setup.py install --force --prefix=/usr/local
ADD wikiconfig.py /usr/local/share/moin/
RUN mkdir /usr/local/share/moin/underlay
RUN chown -R www-data:www-data /usr/local/share/moin/underlay
USER www-data
RUN cd /usr/local/share/moin/ && tar xf underlay.tar -C underlay --strip-components=1
USER root
RUN chown -R www-data:www-data /usr/local/share/moin/data
ADD logo.png /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/common/

# Configure nginx
ADD nginx.conf /etc/nginx/
ADD moinmoin.conf /etc/nginx/sites-available/
RUN mkdir -p /var/cache/nginx/cache
RUN ln -s /etc/nginx/sites-available/moinmoin.conf \
  /etc/nginx/sites-enabled/moinmoin.conf
RUN rm /etc/nginx/sites-enabled/default

# Create self signed certificate
ADD generate_ssl_key.sh /usr/local/bin/
RUN /usr/local/bin/generate_ssl_key.sh moinmoin.example.org
RUN mv cert.pem /etc/ssl/certs/
RUN mv key.pem /etc/ssl/private/

VOLUME /usr/local/share/moin/data

EXPOSE 80
EXPOSE 443

CMD service nginx start && \
  uwsgi --uid www-data \
    -s /tmp/uwsgi.sock \
    --plugins python \
    --pidfile /var/run/uwsgi-moinmoin.pid \
    --wsgi-file server/moin.wsgi \
    -M -p 4 \
    --chdir /usr/local/share/moin \
    --python-path /usr/local/share/moin \
    --harakiri 10 \
    --die-on-term \
    --daemonize /var/log/uwsgi/app/moinmoin.log \ 
  && /bin/bash

