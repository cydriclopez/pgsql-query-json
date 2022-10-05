# Setup Postgresql & Angular Docker working environment.
# Run:
# source docker_alias.sh

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
-v /home/user1/Projects/github/treemodule-json/src/client\
:/home/node/ng/treemodule-json \
-v /home/user1/Projects/github/pgsql-query-json/src/client\
:/home/node/ng/pgsql-query-json \
-w /home/node/ng angular /bin/sh'
