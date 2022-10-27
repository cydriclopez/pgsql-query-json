# cd ~/Projects
# docker compose -f compose-angular.yaml build
# docker compose build
# docker compose up

# Angular is for development only so we will wire it up
# with an alias in ~/Projects/github/pgsql-query-json/src/bashrc.sh
FROM node:14.18-alpine AS angular
RUN npm install -g @angular/cli

# Webapp
FROM debian:bullseye-slim AS webapp-1.0
WORKDIR /root/static
COPY ./client/dist/primeng-quickstart-cli .
WORKDIR /root
COPY ./server/bin .
ENTRYPOINT ["/root/webserv", "/root/static"]
