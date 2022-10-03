-- Tree JSON data-type
create type tree_type as (
    "key"                 int,
    parent                int,
    label                 text,
    icon                  text,
    "expandedIcon"        text,
    "collapsedIcon"       text,
    "data"                text,
    leaf                  boolean,
    toexpand              boolean,
    children              jsonb
);
