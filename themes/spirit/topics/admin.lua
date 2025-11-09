-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: admin
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local common = require('themes.spirit.common')

--- Normalizes admin_level tags
-- @param v The admin_level tag value
-- @return The input value if it is an integer between 0 and 100, or nil otherwise
local function admin_level (v)
    if v and string.find(v, "^%d+$") and tonumber(v) < 100 and tonumber(v) > 0 then
        return tonumber(v)
    end
    return nil
end

local phase2_admin_ways_level = {}
local phase2_admin_ways_parents = {}

themepark:add_table{
    name = 'admin',
    ids_type = 'relation',
    geom = 'point', -- the primary geom used is the label, but areas are needed for admin line processing
    columns = themepark:columns({
        { column = 'names', type = 'jsonb' },
        { column = 'admin_level', type = 'smallint'},
        { column = 'way_area', type = 'real' },
        { column = 'area', type = 'geometry'}
    }),
}

themepark:add_table{
    name = 'admin_lines',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'min_admin_level', type = 'smallint' },
        { column = 'multiple_relations', type = 'boolean'}
    })
}

themepark:add_proc('area', function(object, data)
    if object.type == 'relation' and object.tags.type == 'boundary'
       and object.tags.boundary == 'administrative' then
        local admin = admin_level(object.tags.admin_level)
        if admin and admin >= 2 and admin <= 12 then
            g = object:as_area():transform(3857)
            local a = {
                geom = g:pole_of_inaccessibility(),
                area = g,
                way_area = g:area(),
                admin_level = admin,
                names = common.get_names(object.tags)
            }
            themepark:add_debug_info(a, object.tags)
            themepark:insert('admin', a)
        end
    end
end)

themepark:add_proc('relation', function(object, data)
    if object.tags.type == 'boundary' and object.tags.boundary == 'administrative' then
        local admin = admin_level(object.tags.admin_level)
        if admin ~= nil then
            for _, member in ipairs(object.members) do
                if member.type == 'w' then
                    -- Store the lowest admin_level, and how many relations it used in
                    if not phase2_admin_ways_level[member.ref] then
                        phase2_admin_ways_level[member.ref] = admin
                        phase2_admin_ways_parents[member.ref] = 1
                    else
                        if phase2_admin_ways_level[member.ref] == admin then
                            phase2_admin_ways_parents[member.ref] = phase2_admin_ways_parents[member.ref] + 1
                        elseif admin < phase2_admin_ways_level[member.ref] then
                            phase2_admin_ways_level[member.ref] = admin
                            phase2_admin_ways_parents[member.ref] = 1
                        end
                    end
                end
            end
        end
    end
end)

themepark:add_proc('select_relation_members', function(relation)
    if relation.tags.type == 'boundary' and relation.tags.boundary == 'administrative'
        and admin_level(relation.tags.admin_level) ~= nil then
        return { ways = osm2pgsql.way_member_ids(relation) }
    end
end)

themepark:add_proc('way', function(object, data)
    if osm2pgsql.stage == 1 then
        return
    end

    if phase2_admin_ways_level[object.id] and object.tags.closure_segment ~= 'yes' then
        local a = {
            geom = object:as_linestring(),
            min_admin_level = phase2_admin_ways_level[object.id],
            multiple_relations = (phase2_admin_ways_parents[object.id] > 1)
        }
        themepark:insert('admin_lines', a)
    end
end)
