# pgsql-query-json

## Generate JSON data from PostgreSQL table

> ***This tutorial requires some knowledge in Linux, Docker, Git, Angular, PostgreSQL, and Go Programming Language.***

### Table of Contents
1. [Introduction](https://github.com/cydriclopez/pgsql-query-json#1-introduction)
2. [Goal](https://github.com/cydriclopez/pgsql-query-json#2-goal)
3. [Prerequisites](https://github.com/cydriclopez/pgsql-query-json)
4. [Clone this repo](https://github.com/cydriclopez/pgsql-query-json)
5. [Angular code](https://github.com/cydriclopez/pgsql-query-json)
6. [Go server code](https://github.com/cydriclopez/pgsql-query-json)
7. [PostgreSQL code](https://github.com/cydriclopez/pgsql-query-json)
8. [Running the ***webserv*** app](https://github.com/cydriclopez/pgsql-query-json)
9. [Conclusion](https://github.com/cydriclopez/pgsql-query-json)

### 1. Introduction

This tutorial concludes this series on dealing with JSON data from a tree GUI component. We continue where the [previous tutorial](https://github.com/cydriclopez/pgsql-parse-json) ended.

In this tutorial we write the Angular client code to read JSON data from our Go GET controller code which we will write as well. Our Go controller code will call Postgresql. We will also write a stored-function to generate JSON data.

Our Go controller serves to connect the Angular client code to Postgresql database records. Our Go code has a demo for hosting static files. It also has demo for GET and POST controllers. The Go code is mostly restful and can be called from any client webapp, not necessarily from Angular.

In this tutorial I have tried to simplify the docker code. I have tried to decouple the aliases from the ~/.bashrc file.

### 2. Goal

The goal of this tutorial is to read the tree GUI JSON data from Postgresql and display it in the Angular client web app. This is the reverse of the [previous tutorial's](https://github.com/cydriclopez/pgsql-parse-json) goal which was to write data to the database from our client web app.

Our goal is to read records in table ***tree_data***:

```bash
user1@penguin:~/Projects/pgsql-query-json$
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

And then transform them into JSON format via Postgresql function ***tree_json()***.

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

And then display them in our web app:
<br/>
<kbd><img src="images/primeng-tree-demo3.png" width="650"/></kbd>
<br/>


### 3. Prerequisites
### 4. Clone this repo
### 5. Angular code
### 6. Go server code
### 7. PostgreSQL code
### 8. Running the ***webserv*** app
### 9. Conclusion

---

This is under construction but you can peek into the completed [source code folder](https://github.com/cydriclopez/pgsql-query-json/tree/main/src).😊
