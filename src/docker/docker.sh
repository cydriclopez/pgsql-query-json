#!/bin/bash
# Setup Postgresql & Angular Docker working environment.
# Run:
# source docker.sh

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
-v /home/user1/Projects/pgsql-query-json/src/pgsql\
:/home/psql/pgsql-query-json \
-w /home/psql \
-e POSTGRES_PASSWORD="my-postgres-password" postgres

# Setup Docker PostgreSQL working environment
alias pgstart='docker start postgres14'
alias pgstop='docker stop postgres14'
alias psql='docker exec -it postgres14 psql -U postgres'

# Setup Angular Docker working environment.
# Note the -v folder mapping parameter below in the docker run
# command. Please adjust this according to your situation:
# -v /path/to/your/local/folder:/path/into/the/container/folder
# default ng serve port: 4200
# default ng test port: 9876

alias angular='docker run -it --rm \
-p 4200:4200 -p 9876:9876 \
-v /home/user1/Projects/ng:/home/node/ng \
-v /home/user1/Projects/treemodule-json/src/client\
:/home/node/ng/treemodule-json \
-v /home/user1/Projects/pgsql-query-json/src/client\
:/home/node/ng/pgsql-query-json \
-w /home/node/ng angular /bin/sh'
