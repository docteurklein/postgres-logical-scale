FROM alpine:edge as abuild

RUN apk add --update alpine-sdk

RUN adduser -u 1000 -G abuild -D abuilder
WORKDIR /home/abuilder/build
RUN chown 1000:1000 . && chmod -R 777 /var/cache


USER abuilder

RUN abuild-keygen -a -i

COPY APKBUILD postgresql.pre-upgrade ./

RUN abuild checksum
RUN abuild -r



FROM alpine:edge

COPY --from=abuild /home/abuilder/packages/abuilder/x86_64/ /packages

RUN cd /packages && apk add --no-cache --allow-untrusted *.apk

ENV PGDATA=/var/lib/data/postgres
ENV LANG=en_US.utf8

ARG PG_USER=pguser
ARG PG_PASSWORD=pguser
ARG PG_DB=pguser

ENV IS_MASTER=''
ENV MASTER_HOST=''

EXPOSE 5432

RUN mkdir -p $PGDATA /run/postgresql /etc/postgres && \
    chown postgres:postgres $PGDATA /run/postgresql /etc/postgres

COPY init.sh /

USER postgres

RUN sh /init.sh

VOLUME $PGDATA

COPY entrypoint.sh /
COPY postgres.conf /etc/postgres.conf
COPY hba.conf /etc/postgres.hba

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["postgres",  "-c", "config_file=/etc/postgres.conf"]
