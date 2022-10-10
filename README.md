# pgsql-query-json

## Generate JSON data from PostgreSQL table

> ***This tutorial requires some knowledge in Linux, Docker, Git, Angular, PostgreSQL, and Go Programming Language.***

### Table of Contents
1. [Introduction](https://github.com/cydriclopez/pgsql-query-json#1-introduction)
2. [Goal](https://github.com/cydriclopez/pgsql-query-json#2-goal)
3. [Clone this repo](https://github.com/cydriclopez/pgsql-query-json#3-clone-this-repo)
4. [Docker stuff](https://github.com/cydriclopez/pgsql-query-json#4-docker-stuff)
5. [Client code](https://github.com/cydriclopez/pgsql-query-json#5-client-code)
6. [Go server code](https://github.com/cydriclopez/pgsql-query-json#6-go-server-code)
7. [PostgreSQL code](https://github.com/cydriclopez/pgsql-query-json#7-postgresql-code)
8. [Running the ***webserv*** app](https://github.com/cydriclopez/pgsql-query-json#8-running-the-go-webserv-app)
9. [Conclusion](https://github.com/cydriclopez/pgsql-query-json#9-conclusion)

### 1. Introduction

We continue where the [previous tutorial](https://github.com/cydriclopez/pgsql-parse-json) ended. This tutorial concludes this series on dealing with JSON data from a tree GUI component.

In this tutorial we write the Angular client code to read JSON data from our Go GET controller code which we will write as well. Our Go controller code will call Postgresql. We will also write a stored-function to generate JSON data.

Our Go controller serves to connect the Angular client code to Postgresql database records. Our Go code has a demo for hosting static files. It also has demo for GET and POST controllers. The Go code is mostly restful and can be called from any client webapp, not necessarily from Angular.

In this tutorial I have tried to simplify the docker code. I have tried to decouple the aliases from the ~/.bashrc file.

### 2. Goal

The goal of this tutorial is to read the tree GUI JSON data from Postgresql and display it in the Angular client web app. This is the reverse of the [previous tutorial's](https://github.com/cydriclopez/pgsql-parse-json) goal which was to write data to the database from our client web app.

Our goal is to read records in table ***tree_data***:

```bash
user1@penguin:~/Projects/github/pgsql-query-json$
:psql
psql (14.2 (Debian 14.2-1.pgdg110+1))
Type "help" for help.

postgres=# select * from tree_data;
 key | parent |     label      |    icon     |   expandedicon    | collapsedicon |          data           | leaf | toexpand
-----+--------+----------------+-------------+-------------------+---------------+-------------------------+------+----------
   1 |      0 | data           |             |                   |               | data                    | f    | t
   2 |      1 | Documents      |             | pi pi-folder-open | pi pi-folder  | Documents Folder        | f    | f
   3 |      2 | Work           |             | pi pi-folder-open | pi pi-folder  | Work Folder             | f    | f
   4 |      3 | Expenses.doc   | pi pi-file  |                   |               | Expenses Document       | t    | f
   5 |      3 | Resume.doc     | pi pi-file  |                   |               | Resume Document         | t    | f
   6 |      2 | Home           |             | pi pi-folder-open | pi pi-folder  | Home Folder             | f    | f
   7 |      6 | Invoices.txt   | pi pi-file  |                   |               | Invoices for this month | t    | f
   8 |      1 | Pictures       |             | pi pi-folder-open | pi pi-folder  | Pictures Folder         | f    | f
   9 |      8 | barcelona.jpg  | pi pi-image |                   |               | Barcelona Photo         | t    | f
  10 |      8 | logo.jpg       | pi pi-image |                   |               | PrimeFaces Logo         | t    | f
  11 |      8 | primeui.png    | pi pi-image |                   |               | PrimeUI Logo            | t    | f
  12 |      1 | Movies         |             | pi pi-folder-open | pi pi-folder  | Movies Folder           | f    | t
  13 |     12 | Al Pacino      |             |                   |               | Pacino Movies           | f    | f
  14 |     13 | Scarface       | pi pi-video |                   |               | Scarface Movie          | t    | f
  15 |     13 | Serpico        | pi pi-video |                   |               | Serpico Movie           | t    | f
  16 |     12 | Robert De Niro |             |                   |               | De Niro Movies          | f    | f
  17 |     16 | Goodfellas     | pi pi-video |                   |               | Goodfellas Movie        | t    | f
  18 |     16 | Untouchables   | pi pi-video |                   |               | Untouchables Movie      | t    | f
(18 rows)
```

And then transform them into JSON format via Postgresql function [tree_json()](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/pgsql/tree_json.sql).

```bash
postgres=# select jsonb_pretty(tree_json());
                          jsonb_pretty
----------------------------------------------------------------
 {                                                             +
     "data": [                                                 +
         {                                                     +
             "data": "Documents Folder",                       +
             "label": "Documents",                             +
             "children": [                                     +
                 {                                             +
                     "data": "Work Folder",                    +
                     "label": "Work",                          +
                     "children": [                             +
                         {                                     +
                             "data": "Expenses Document",      +
                             "icon": "pi pi-file",             +
                             "label": "Expenses.doc"           +
                         },                                    +
                         {                                     +
                             "data": "Resume Document",        +
                             "icon": "pi pi-file",             +
                             "label": "Resume.doc"             +
                         }                                     +
                     ],                                        +
                     "toexpand": false,                        +
                     "expandedIcon": "pi pi-folder-open",      +
                     "collapsedIcon": "pi pi-folder"           +
                 },                                            +
                 {                                             +
                     "data": "Home Folder",                    +
--More--
```

And then feed this JSON data into our web app for display in our tree component:
<br/>
<kbd><img src="images/primeng-tree-demo3.png" width="650"/></kbd>
<br/>

### 3. Clone this repo

I assume you know about [GNU/Linux](https://www.debian.org/releases/jessie/amd64/ch01s02.html.en). I also assume you have [Docker](https://docs.docker.com/engine/install/) and [Git](https://git-scm.com/download/linux) installed. These are basic essentials for software developers these days and life without them is just impossible.😊

In my ***~/.bashrc*** file I have a line ***export PS1=$PS1'\n:'*** which results in my command line prompt as shown below (i.e. ***user1@penguin:~\$***). This way no matter how long is my path, my prompt is always on the next line down then second character from the left and right after the colon ":" character. I have just added extra line-feed and comments (starts with #) between prompts for clarity.

To lessen confusion, as far as folders are concerned, I have adopted ***~/Projects/github/*** as the root project folder for this tutorial. I trust that you know what you are doing if you divert from this norm.

Follow carefully the command line instructions (cli) below to clone this project.

```bash
# From your home folder make a directory ~/Projects/github.
# The -p parameter creates the whole path if it does not exist.
user1@penguin:~$
:mkdir -p ~/Projects/github

# Change directory into the just created folder
user1@penguin:~$
:cd ~/Projects/github

# Clone this project
user1@penguin:~/Projects/github$
:git clone https://github.com/cydriclopez/pgsql-query-json.git

# Change directory into the just cloned docker stuff folder.
user1@penguin:~/Projects/github$
:cd pgsql-query-json/src/docker

# This is the folder with all the docker stuff discussed next
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:
```

### 4. Docker stuff

#### 4.1. Learning by sharing

I have tried to decouple my "docker run" aliases from the ***~/.bashrc*** file. You can tell that I am new to this thing. I learn as I go. Nothing beats learning by having to teach it. As the adage goes "You can only teach what you have learned." Or, "If you cannot teach it, then you haven't really learned it." 😊

#### 4.2. Docker code list

Our Docker code consists of 5 files located in folder [src/docker](https://github.com/cydriclopez/pgsql-query-json/tree/main/src/docker).

| # | file   | location | purpose |
| --- | ----------- | --- | ----------- |
| 1 | angular.dockerfile | [src/docker/angular.dockerfile](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/docker/angular.dockerfile) | create Angular image |
| 2 | docker_alias.sh | [src/docker/docker_alias.sh](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/docker/docker_alias.sh) | create "docker run" aliases |
| 3 | docker_init.sh | [src/docker/docker_init.sh](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/docker/docker_init.sh) | create Angular & Postgresql containers |
| 4 | postgres.dockerfile | [src/docker/postgres.dockerfile](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/docker/postgres.dockerfile) | create Postgresql image |
| 5 | README.md | [src/docker/README.md](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/docker/README.md) | readme file |

#### 4.3. Docker images, containers, and aliases

As shown below we will run ***source docker_init.sh*** to create the Angular & Postgresql images and containers (the running instance of images). This we will only run once. After our images and containers are created then we can simply run ***source docker_alias.sh*** to create our aliases. These aliases are shortcuts to docker commands.

Follow carefully the terminal command line instructions (cli) below to create the needed docker images and containers for this project. Comment lines start with character "#".

```bash
# ll is my alias for "ls --color -lah --group-directories-first" command
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:ll

drwxr-xr-x 1 user1 user1  150 Oct  5 13:32 .
drwxr-xr-x 1 user1 user1   46 Oct  2 21:25 ..
-rw-r--r-- 1 user1 user1  500 Oct  5 13:39 angular.dockerfile
-rw-r--r-- 1 user1 user1  889 Oct  5 13:36 docker_alias.sh
-rw-r--r-- 1 user1 user1 1.2K Oct  5 13:36 docker_init.sh
-rw-r--r-- 1 user1 user1  239 Oct  5 13:38 postgres.dockerfile
-rw-r--r-- 1 user1 user1   22 Oct  2 22:39 README.md

# Run "source docker_init.sh" to create the Angular &
# Postgresql images. This will also run "source docker_alias.sh"
# to create the Angular & Postgresql containers.
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:source docker_init.sh
 .
 :
[truncated Docker messages]
 .
 :
# At this point our Angular & Postgresql images & containers are ready
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:pgstart
postgres14

# Now that Postgresql is up, let's connect to it with "psql"
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:psql

psql (14.5 (Debian 14.5-1.pgdg110+1))
Type "help" for help.

# You are now inside the Postgresql docker container.
# Try query the Postgresql version.
postgres=# select version();
                                                           version
-----------------------------------------------------------------------------------------------------------------------------
 PostgreSQL 14.5 (Debian 14.5-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
(1 row)

# The query "select version();" works!
# For now let's exit out of Postgresql.
postgres=# \q

# We are back into our bash console. Try run Angular.
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:angular

# You are now inside the Angular docker container.
# Display the Angular version.
/home/node/ng # ng -v
     _                      _                 ____ _     ___
    / \   _ __   __ _ _   _| | __ _ _ __     / ___| |   |_ _|
   / △ \ | '_ \ / _` | | | | |/ _` | '__|   | |   | |    | |
  / ___ \| | | | (_| | |_| | | (_| | |      | |___| |___ | |
 /_/   \_\_| |_|\__, |\__,_|_|\__,_|_|       \____|_____|___|
                |___/

Angular CLI: 14.2.5
Node: 14.18.3
Package Manager: npm 6.14.15
OS: linux x64

Angular:
...

Package                      Version
------------------------------------------------------
@angular-devkit/architect    0.1402.5 (cli-only)
@angular-devkit/core         14.2.5 (cli-only)
@angular-devkit/schematics   14.2.5 (cli-only)
@schematics/angular          14.2.5 (cli-only)

# Yay! Angular works! Let's exit for now.
/home/node/ng # exit

# We are back again in our local bash session.
# We'll take a look at the Angular code next.
user1@penguin:~/Projects/github/pgsql-query-json/src/docker$
:
```

#### 4.4. Merits of OS-level virtualization

Gone are the days of the mind-numbing complexity of manually installing software. Using Docker images and containers beat having to manually install software for development and deployment. Docker just solves a lot of IT pain in software development and deployment.

<ins>**IT departments, who are not yet availing of OS-level virtualization or software container systems, are still in the IT dark ages.**</ins> These are valuable solutions for several key tough challenges in IT.

There are now alternatives in [Podman and Buildah](https://developers.redhat.com/blog/2019/02/21/podman-and-buildah-for-docker-users), or even [LXD/LXC](https://linuxcontainers.org/lxd/) that are quite effective and highly useful.

### 5. Client code

#### 5.1. Client code origin

This demo code started out as a clone of the [PrimeNG Angular-CLI](https://github.com/primefaces/primeng-quickstart-cli) project. I have largely maintained this demo code project. I tweaked it to make room for the tree-demo page by adding the ***Tree Demo*** button and implemented routing. It is in the ***Tree Demo*** page where we implement the client code in this tutorial.

Our client code is written in ***Angular/TypeScript*** but it can be translated to any other web framework. People make a big deal of Angular's learning curve. Once you get over Angular's being a highly opinionated framework, then you will realize it is quite elegantly designed actually. Angular projects tend to be modular and thus manageable.

Angular has built-in formalizations of stuff like Components, Directives, Dependency Injection, Singleton Service, PWA web service worker, RxJS Observables, Jasmine-Karma testing, and etc. These are all built-in baked into Angular. In other frameworks these may be provided by separate and disparate 3rd-party libraries. The latest Angular compiler has greatly improved in generating smaller code.

#### 5.2. Client code GUI

I added the ***Tree Demo*** button to display the tree-demo page:
<br/>
<img src="images/primeng-quickstart-cli.png" width="650"/>
<br/>

The ***Tree Demo*** page where we implement the client code in this tutorial:
<br/>
<kbd><img src="images/primeng-tree-demo3.png" width="650"/></kbd>
<br/>

#### 5.3. Client code organization

Our Angular code consists of 6 files located in folder [src/client/src/app](https://github.com/cydriclopez/pgsql-query-json/tree/main/src/client/src/app). They are sorted by function.

| # | file   | location | purpose |
| --- | ----------- | --- | ----------- |
| 1 | treedemo.component.html | [src/client/src/app/treedemo/treedemo.component.html](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/client/src/app/treedemo/treedemo.component.html) | treedemo component template |
| 2 | treedemo.component.ts | [src/client/src/app/treedemo/treedemo.component.ts](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/client/src/app/treedemo/treedemo.component.ts) | treedemo component class |
| 3 | nodeservice.ts | [src/client/src/app/services/nodeservice.ts](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/client/src/app/services/nodeservice.ts) | treedemo data service |
| 4 | home.component.html | [src/client/src/app/home/home.component.html](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/client/src/app/home/home.component.html) | main template with nothing but router outlet |
| 5 | home.component.ts | [src/client/src/app/home/home.component.ts](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/client/src/app/home/home.component.ts) | default component without much functionality |
| 6 | app.module.ts | [src/client/src/app/app.module.ts](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/client/src/app/app.module.ts) | inherited much from Primeng demo but added routing functionality |

The client code is pretty basic. Much of the functionality in talking to the server-side Go code is implemented in ***#3 nodeservice.ts*** which is declared as a singleton class. This is a simple demo that introduces the idea of using Angular's singleton service as the canonical source of application state or data your app may need.

I use a basic existing public demo code and simply tweak them into how I would like to see them coded if I were the **IT Manager** or **Tech Lead**. A simple solid basic foundation wards off a lot of future refactoring headaches. My goal is to preach the idea that components are for UI display. Application state, data, and logic must be off-loaded to a service.

When your app expands in feature and functionality, components that need access to a central state or data can be loosely coupled using observables defined within a service. It is in this code modularization that Angular shines. **Checkout Angular you may just like it!**

#### 5.4. Compiling Angular code

Follow carefully the terminal command line instructions below to compile our Angular project. Comment lines start with character "#".

```bash
# From your home folder cd into this project's cloned folder
user1@penguin:~$
:cd ~/Projects/github/pgsql-query-json

# Load docker alias definitions from docker_alias.sh
user1@penguin:~/Projects/github/pgsql-query-json$
:source src/docker/docker_alias.sh

# With docker aliases loaded we can now run "angular"
user1@penguin:~/Projects/github/pgsql-query-json$
:angular

# Now we are inside the Angular docker container.
# Let us list the contents in this directory.
/home/node/ng # ls -l

drwxr-xr-x    1 root     root             0 Jul 28 23:51 go-post-json-passthru
drwxr-xr-x    1 node     node           272 Oct  3 05:35 pgsql-query-json
drwxr-xr-x    1 node     node           248 Jul 28 23:41 treemodule-json
```

The directory listing above is the result of our Angular alias definition. Note that in [4.2. Docker code list](https://github.com/cydriclopez/pgsql-query-json#42-docker-code-list) bash script [docker_alias.sh](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/docker/docker_alias.sh) we defined the ***angular*** alias as:

```bash
alias angular='docker run -it --rm \
-p 4200:4200 -p 9876:9876 \
-v /home/user1/Projects/ng:/home/node/ng \
-v /home/user1/Projects/github/treemodule-json/src/client\
:/home/node/ng/treemodule-json \
-v /home/user1/Projects/github/pgsql-query-json/src/client\
:/home/node/ng/pgsql-query-json \
-w /home/node/ng angular /bin/sh'
```

The directory listing above is the accumulation of mapped directories using the ***-v*** parameter in the ***Angular*** alias definition above.

Now let us continue with our preceding bash session:
```bash
# Now we are inside the Angular docker container.
# We cd into our project folder pgsql-query-json
/home/node/ng # cd pgsql-query-json

# This is actually our local folder
# ~/Projects/github/pgsql-query-json/src/client
# mapped into the container's folder
# /home/node/ng/pgsql-query-json
# Here we compile our Angular project with "ng build --watch".
# "--watch" automatically recompile on any code changes.
# This will take a few seconds.
/home/node/ng/pgsql-query-json # ng build --watch

✔ Browser application bundle generation complete.
✔ Index html generation complete.

Initial Chunk Files | Names         |      Size
vendor.js           | vendor        |   3.64 MB
styles.css          | styles        | 241.78 kB
polyfills.js        | polyfills     | 216.88 kB
main.js             | main          |  63.03 kB
runtime.js          | runtime       |   6.40 kB

                    | Initial Total |   4.15 MB

Build at: 2022-10-10T10:32:50.778Z - Hash: b6290d8b6a48d34a - Time: 9645ms

# At this point our Angular code is compiled into a bunch of
# Javascript and other static asset files.
# We press ctrl+c to exit.
^C
# Then type exit to exit out of the Angular docker container
/home/node/ng/pgsql-query-json # exit

# Now we are back in our local bash session
user1@penguin:~/Projects/github/pgsql-query-json$
:
```

At this point Angular static code is generated in our local folder: ***~/Projects/github/pgsql-query-json/src/client/dist/primeng-quickstart-cli***

This is the directory we will feed our Go server app ***webserv*** which we will discuss next.


### 6. Go server code

#### 6.1. Go server-side code organization

Our Go server-side code consists of 4 packages files located in [src/server](https://github.com/cydriclopez/pgsql-query-json/tree/main/src/server) directory. We have mostly inherited from the Go code in the previous tutorial [Parse JSON in PostgreSQL to save records](https://github.com/cydriclopez/pgsql-parse-json). The Go server-side code is simple. Most of our new code is in the [treedata](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/server/treedata/treedata.go) package.

| # | package   | file | purpose |
| --- | ----------- | --- | ----------- |
| 1 | main | [src/server/webserv.go](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/server/webserv.go) | main ***webserv*** executable  |
| 2 | common | [src/server/common/common.go](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/server/common/common.go) | Postgresql connector  |
| 3 | params | [src/server/params/params.go](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/server/params/params.go) | process the command-line args |
| 4 | treedata | [src/server/treedata/treedata.go](https://github.com/cydriclopez/pgsql-query-json/blob/main/src/server/treedata/treedata.go) | process the tree JSON data |


### 7. PostgreSQL code
### 8. Running the Go ***webserv*** app
### 9. Conclusion

---

This is under construction but you can peek into the completed [source code folder](https://github.com/cydriclopez/pgsql-query-json/tree/main/src).😊
