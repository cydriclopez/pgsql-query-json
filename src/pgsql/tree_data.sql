-- Tree JSON data-store
create table tree_data (
  "key"                 int generated always as identity primary key,
  parent                int,
  label                 text,
  icon                  text,
  expandedIcon          text,
  collapsedIcon         text,
  "data"                text,
  leaf                  boolean,
  toexpand              boolean
);
