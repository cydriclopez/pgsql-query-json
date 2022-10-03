# postgres.dockerfile
# Dockerize your PostgreSQL dev environment.
# Run:
# docker build -f postgres.dockerfile -t postgres .

# So you won't be typing "sudo docker" a lot, suggested
# Linux Docker post install commands:
# sudo groupadd docker
# sudo usermod -aG docker $USER

FROM postgres:14
RUN mkdir -p /home/psql
