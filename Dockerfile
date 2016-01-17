FROM python:3-onbuild
MAINTAINER <sdelrio@users.noreply.github.com>
RUN apt-get update \
 && apt-get remove --purge -y libsqlite3-0 \
 && apt-get install -y build-essential psmisc \
 && apt-get install -y fuse libfuse-dev libattr1-dev pkg-config wget \
 && pip install pkgconfig Crypto defusedxml pycrypto

#WORKDIR /usr/src
RUN apt-get install -y wget \
 && wget http://www.sqlite.org/2016/sqlite-autoconf-3100000.tar.gz \
 && tar xzvf sqlite-autoconf-3100000.tar.gz \
 && cd sqlite-autoconf-3100000 \
 && ./configure --prefix=/usr --enable-shared \
 && make && make install \
 && pip install apsw llfuse dugong \
 && cd

#WORKDIR /usr/src
RUN wget https://bitbucket.org/nikratio/s3ql/downloads/s3ql-2.15.tar.bz2 \
 && tar xjvf s3ql-2.15.tar.bz2 \
 && cd s3ql-2.15 \
 && python3 setup.py build_ext --inplace \
 && ls bin \
 && python3 setup.py install \
 && cd

RUN rm -rf s3ql-2.15.tar.bz2 s3ql-2.15 sqlite-autoconf-3100000.tar.gz sqlite-autoconf-3100000 \
 && apt-get remove --purge -y build-essential make manpages manpages-dev patch perl perl-modules rename xz-utils \
 && apt-get autoremove -y \
 && apt-get remove -y libattr1-dev libfuse-dev libpcre3-dev libc6-dev libselinux1-dev libsepol1-dev linux-libc-dev libpcre3-dev libc-dev-bin pkg-config wget 

RUN mkdir /mnt/hubic \
 && mkdir /tmp/hubic_cache

RUN apt-get install -y bash

RUN mkdir /root/.s3ql
ADD config/authinfo2 /root/.s3ql/authinfo2
RUN chmod 600 /root/.s3ql/authinfo2

ADD bin/run_s3qlconfig.sh /usr/bin/run_s3qlconfig.sh

VOLUME ["/mnt/hubic"]

CMD ["/usr/bin/run_s3qlconfig.sh"]
