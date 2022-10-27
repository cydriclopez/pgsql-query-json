# bashrc.sh
# ~/.bashrc extensions
# cl 10/20/2022
# In ~/.bashrc add this line:
# source ~/Projects/github/pgsql-query-json/src/bashrc.sh

export PS1=$PS1'\n:'
export PATH=/usr/local/go/bin:~/go/bin:$PATH

alias ll='ls -lah --color=auto --group-directories-first'
alias x='exit'

# A faster way to navigate folders.
# https://github.com/EskelinenAntti/cdir
alias cdir='source cdir.sh'

# Alias gom requires https://github.com/c9s/gomon
# Remember to: mkdir -p src/server/bin
# It is where gom will stuff the Go executable.
# Run gom in the root Go package src/server folder.
# So ./bin folder will have contents initially
# run: go build -o ./bin
# In compose.yaml -> volume: ./server/bin:/root
alias gom='gomon . ./*/*.go -- go build -o ./bin'

# In compose.yaml -> container_name: postgres14
alias psql='docker exec -it postgres14 psql -U postgres'

# In compose-angular.yaml -> container_name: angular
alias angular='docker run -it --rm \
-p 4200:4200 -p 9876:9876 \
-v /home/user1/Projects/github/pgsql-query-json/src/client\
:/home/node/pgsql-query-json \
-w /home angular /bin/sh'

date
