# Custom MySQL for Dynamic Project
ARG MYSQL_VERSION=8.0
FROM mysql:${MYSQL_VERSION}

# Copy custom MySQL configurations
COPY conf.d/ /etc/mysql/conf.d/

# Labels for identification
ARG PROJECT_NAME=devkraken
LABEL maintainer="${PROJECT_NAME}"
LABEL description="Custom MySQL for WordPress"
LABEL version="1.0"
LABEL project="${PROJECT_NAME}"

EXPOSE 3306

# Use the default MySQL entrypoint
CMD ["mysqld"] 