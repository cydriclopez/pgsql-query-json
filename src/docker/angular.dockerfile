# angular.dockerfile
# Dockerize your Angular dev environment.
# Run:
# docker build -f angular.dockerfile -t angular .

# So you won't be typing "sudo docker" a lot, suggested
# Linux Docker post install commands:
# sudo groupadd docker
# sudo usermod -aG docker $USER

# IMPORTANT NOTE:
# Code generated from inside the container will be owned by the root
# account which will make them read-only from your code editor. This
# can be corrected by running the command:
#
# sudo chown -R $USER:$USER <generated-code-folder-name>

FROM node:14.18-alpine
RUN npm install -g @angular/cli