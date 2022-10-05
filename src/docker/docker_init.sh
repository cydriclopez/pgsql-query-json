# Setup Postgresql & Angular Docker working environment.
# Run:
# source docker_init.sh

# Rebuild images
docker rmi -f angular
docker rmi -f postgres
docker build -f angular.dockerfile -t angular .
docker build -f postgres.dockerfile -t postgres .

# This script will run the postgres image in detached mode, name
# it postgres14, and create volume postgres_volume if not existing.
# This volume provides persistence when the container ceases running.
# It will also bind mount your project folder as the working folder.

# Setup Postgresql Docker working environment.
# Note the -v folder mapping parameter below in the docker run
# command. Please adjust this according to your situation:
# -v /path/to/your/local/folder:/path/into/the/container/folder
docker stop postgres14
docker rm postgres14
docker run -d --name=postgres14 -p 5432:5432 \
--mount source=postgres_volume,target=/var/lib/postgresql/data \
-v /home/user1/Projects/psql:/home/psql \
-v /home/user1/Projects/github/pgsql-query-json/src/pgsql\
:/home/psql/pgsql-query-json \
-w /home/psql \
-e POSTGRES_PASSWORD="my-postgres-password" postgres

# Setup aliases to run Postgresql & Angular docker containers
source docker_alias.sh
