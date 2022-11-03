# Multi-stage build using golang image
# 1. cd ~/Projects/github/pgsql-query-json/src
# 2. docker compose -f compose-angular.yaml build
# 3. docker compose build
# 4. docker compose up

# Angular is for development only so we will
# drive it with an alias in alias.sh.
FROM node:14.18-alpine AS angular
RUN npm install -g @angular/cli

# Builder stage
# Use golang compiler image
FROM golang:bullseye AS builder
WORKDIR /code/bin/static
WORKDIR /code
COPY ./server .
RUN go mod download && go mod verify
# Compile into bin folder
RUN go build -o ./bin
# Copy Angular compiled static files
WORKDIR /code/bin/static
COPY ./client/dist/primeng-quickstart-cli .

# Final stage
# Use recommended debian slim image.
# Alpine images are experimental.
FROM debian:bullseye-slim AS webapp-1.0
WORKDIR /root
COPY --from=builder /code/bin .
ENTRYPOINT ["/root/webserv", "/root/static"]
