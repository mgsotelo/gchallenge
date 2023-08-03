FROM mysql:latest
ENV MYSQL_ROOT_PASSWORD ${MYSQL_ROOT_PASSWORD}
COPY scripts/database.sql /docker-entrypoint-initdb.d/
EXPOSE 3306
CMD ["--default-authentication-plugin=mysql_native_password"]