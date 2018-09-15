# VERSION 0.6
# AUTHOR:         Olav Grønås Gjerde <olav@backupbay.com>
# DESCRIPTION:    Image with MoinMoin wiki, uwsgi, nginx and self signed SSL
# TO_BUILD:       docker build -t moinmoin .
# TO_RUN:         docker run -d -p 80:80 -p 443:443 --name my_wiki moinmoin

FROM debian:stretch-slim
MAINTAINER Olav Grønås Gjerde <olav@backupbay.com>

# Set the version you want of MoinMoin
ENV MM_VERSION 1.9.10
ENV MM_CSUM 6ae110a22a23bfa6dd5c149b8d66f7ad34976d5d

# Install software
RUN apt-get update && apt-get install -qqy --no-install-recommends \
  python2.7 \
  curl \
  openssl \
  nginx \
  uwsgi \
  uwsgi-plugin-python \
  rsyslog

# Download MoinMoin
RUN curl -OkL \
  https://github.com/moinwiki/moin-1.9/releases/download/$MM_VERSION/moin-$MM_VERSION.tar.gz
RUN if [ "$MM_CSUM" != "$(sha1sum moin-$MM_VERSION.tar.gz | awk '{print($1)}')" ];\
  then exit 1; fi;
RUN mkdir moinmoin
RUN tar xf moin-$MM_VERSION.tar.gz -C moinmoin --strip-components=1

# Install MoinMoin
RUN cd moinmoin && python2.7 setup.py install --force --prefix=/usr/local
ADD wikiconfig.py /usr/local/share/moin/
RUN chown -Rh www-data:www-data /usr/local/share/moin/underlay
USER root

# Copy default data into a new folder, we will use this to add content
# if you start a new container using volumes
RUN cp -r /usr/local/share/moin/data /usr/local/share/moin/bootstrap-data

RUN chown -R www-data:www-data /usr/local/share/moin/data
ADD logo.png /usr/local/lib/python2.7/dist-packages/MoinMoin/web/static/htdocs/common/

# Configure nginx
ADD nginx.conf /etc/nginx/
ADD moinmoin-nossl.conf /etc/nginx/sites-available/
ADD moinmoin-ssl.conf /etc/nginx/sites-available/
RUN mkdir -p /var/cache/nginx/cache
RUN rm /etc/nginx/sites-enabled/default

# Create self signed certificate
ADD generate_ssl_key.sh /usr/local/bin/
RUN /usr/local/bin/generate_ssl_key.sh moinmoin.example.org
RUN mv cert.pem /etc/ssl/certs/
RUN mv key.pem /etc/ssl/private/

# Cleanup
RUN rm moin-$MM_VERSION.tar.gz
RUN rm -rf /moinmoin
RUN apt-get purge -qqy curl
RUN apt-get autoremove -qqy && apt-get clean
RUN rm -rf /tmp/* /var/lib/apt/lists/*

# Add the start shell script
ADD start.sh /usr/local/bin/

VOLUME /usr/local/share/moin/data

EXPOSE 80
EXPOSE 443

CMD start.sh
