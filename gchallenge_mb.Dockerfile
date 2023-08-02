FROM metabase/metabase:v0.46.6.2

RUN apk add --update mysql-client

VOLUME [ "/metabase.db" ]