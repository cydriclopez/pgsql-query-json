-- Parse tree json data and save records
-- CL 9/1/2022
create or replace function tree_insert(
    children   jsonb,           -- json to recourse into
    parent     int default 0    -- the parent key
) returns void as
$$
declare
    _record     record;
    _leaf       boolean default false;
    _key        int;

begin
    -- Clear table & insert root record
    if tree_insert.parent = 0 then
        -- First clear output table & reset pk
        truncate tree_data restart identity;

        -- Initial serial PK "key" is the first parent
        insert into tree_data (parent, leaf, label, "data", toexpand)
            values (0, false, 'data', 'data', true)
            returning "key" into tree_insert.parent;
    end if;

    -- Loop thru the children json array using type tree_type
    for _record in
        select
            js.key,
            js.parent,
            js.label,
            js.icon,
            js."expandedIcon",
            js."collapsedIcon",
            js.data,
            js.toexpand,
            js.children

        -- Read documentation on jsonb_populate_recordset()
        from jsonb_populate_recordset(
            null::tree_type,
            tree_insert.children) as js
        loop
            -- Check if entry has children
            _leaf = _record.children is null;

            -- Set toexpand to false if it's null
            _record.toexpand = coalesce(_record.toexpand, false);

            -- Inserted serial PK "key" is the parent in
            -- the succeeding recursive call if it has children.
            insert into tree_data (parent, label, icon, expandedIcon,
                    collapsedIcon, "data", leaf, toexpand)
                values (tree_insert.parent, _record.label, _record.icon,
                    _record."expandedIcon",  _record."collapsedIcon",
                    _record.data, _leaf, _record.toexpand)
                returning "key" into _key;

            -- Recursive call to read next json array entry.
            -- Inserted serial PK "key" is parent for next children.
            if not _leaf then
                perform tree_insert(
                    _record.children,   -- next json segment to scan
                    _key                -- the new parent
                );
            end if;
        end loop;

    return;
end;
$$
language plpgsql;
