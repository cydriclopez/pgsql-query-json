# Dockerize your PostgreSQL dev environment
# Run:
# docker build -f postgres.dockerfile -t postgres .

# Linux Docker post install commands:
# sudo groupadd docker
# sudo usermod -aG docker $USER

FROM postgres:14
RUN mkdir -p /home/psql
