# In compose.yaml -> container_name: postgres14
alias psql='docker exec -it postgres14 psql -U postgres'

# In compose-angular.yaml -> container_name: angular
alias angular='docker run -it --rm \
-p 4200:4200 -p 9876:9876 \
-v ~/Projects/github/pgsql-query-json/src/client\
:/home/node/pgsql-query-json \
-w /home/node angular /bin/sh'
