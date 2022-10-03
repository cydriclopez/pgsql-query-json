-- Query json data from table tree_data
-- CL 9/17/2022

-- In psql test with:
-- \! ls -l                           <-- list files in folder
-- \cd pgsql-query-json               <-- cd into sql project folder
-- \i tree_json.sql                   <-- Run this file create function
-- select jsonb_pretty(tree_json());  <-- Run function tree_json()

-- Initial call with parent = 0 by default to include all rows.
create or replace function tree_json(
    parent int default 0
) returns jsonb as
$$
declare
    _key int;
    _parent int;
    _label text;
    _data text;
    _expandedIcon text;
    _collapsedIcon text;
    _icon text;
    _leaf boolean;
    _toexpand boolean;

begin
    -- The parameter parent = 0 by default so
    -- this "if condition" is true once at the start.
    if tree_json.parent = 0 then

        -- Get the root parent = 0 record. Note that
        -- in tree_insert.sql this is written as the 1st row.
        select "key", T.parent, label, "data", expandedIcon,
                collapsedIcon, icon, leaf, toexpand
            into _key, _parent, _label, _data, _expandedIcon,
                _collapsedIcon, _icon, _leaf, _toexpand
            from tree_data T
            where T.parent = tree_json.parent;

        -- Setup the outer-most data array
        return jsonb_build_object(
            'data', array(

                -- First recursive call for all child nodes
                select tree_json("key")
                    from tree_data T
                    where T.parent = _key
            )
        );

    else

        -- Get row values for this current iteration
        select "key", T.parent, label, "data", expandedIcon,
                collapsedIcon, icon, leaf, toexpand
            into _key, _parent, _label, _data, _expandedIcon,
                _collapsedIcon, _icon, _leaf, _toexpand
            from tree_data T
            where "key" = tree_json.parent;

    end if;

    -- Check if row is a parent
    if not _leaf then

        return jsonb_build_object(
            'label', _label,
            'data', _data,
            'expandedIcon', _expandedIcon,
            'collapsedIcon', _collapsedIcon,
            'toexpand', _toexpand,
            'children', array(

                -- Recursive call for sub-child nodes
                select tree_json("key")
                    from tree_data T
                    where T.parent = tree_json.parent
            )
        );

    else

        -- This row is a leaf node
        return jsonb_build_object(
            'label', _label,
            'data', _data,
            'icon', _icon
        );

    end if;

end;
$$
language plpgsql;
