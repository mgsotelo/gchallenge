FROM mysql:latest
ENV MYSQL_ROOT_PASSWORD ${MYSQL_ROOT_PASSWORD}
COPY scripts/database.sql /docker-entrypoint-initdb.d/
EXPOSE 3306

# Additional command to complement the CMD from the base image
CMD ["sh", "-c", "docker-entrypoint.sh mysqld && rm -rf /var/lib/mysql/*.pem"]