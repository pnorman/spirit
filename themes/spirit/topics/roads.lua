-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: roads
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'roads',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'highway', type = 'text' },
        { column = 'name', type = 'text' },
        { column = 'ref', type = 'text' },
        { column = 'oneway', type = 'text' },
        { column = 'minor', type = 'boolean' },
        { column = 'bridge', type = 'boolean' },
        { column = 'tunnel', type = 'boolean' },
        { column = 'layer', type = 'smallint' },
        { column = 'z_order', type = 'smallint' },
    }),
    indexes = {
        { column = 'geom',
          method = 'gist',
          where = "highway IN ('motorway', 'motorway_link', 'trunk', 'trunk_link', 'primary', 'primary_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link')"}}
}

themepark:add_table{
    name = 'road_routes',
    ids_type = 'relation',
    columns = themepark:columns({
        { column = 'member_id', type = 'int8' },
        { column = 'member_position', type = 'int4' },
        { column = 'ref', type = 'text' },
        { column = 'network', type = 'text' }
    }),
}

-- z_order value. Must be a multiple of 10, because construction divides it by 10
local z_order = {
    motorway = 380,
    trunk = 370,
    primary = 360,
    secondary = 350,
    tertiary = 340,
    road = 330,
    unclassified = 330,
    residential = 330,
    living_street = 320,
    pedestrian = 310,
    motorway_link = 240,
    trunk_link = 230,
    primary_link = 220,
    secondary_link = 210,
    tertiary_link = 200,
    busway = 170,
    service = 150,
    bridleway = 100,
    footway = 100,
    cycleway = 100,
    path = 100,
    construction = 0
}

local minor_service = {'parking_aisle', 'drive-through', 'driveway'}
themepark:add_proc('way', function(object, data)
    local z = z_order[object.tags.highway]
    if z then
        if object.tags.highway == 'construction' then
            if object.tags.construction and z_order[object.tags.construction] then
                z = z_order[object.tags.construction]/10
            else
                z = z_order['road']/10
            end
        end
        local a = { name = object.tags.name,
                    highway = object.tags.highway,
                    ref = object.tags.ref,
                    oneway = object.tags.oneway,
                    layer = common.layer(object.tags.layer),
                    z_order = z,
                    geom = object.as_linestring() }
        if common.contains(minor_service, object.tags.service) then
            a.minor = true
        end
        if object.tags.bridge and object.tags.bridge ~= 'no' then
            a.bridge = true
        end
        if object.tags.tunnel and object.tags.tunnel ~= 'no' then
            a.tunnel = true
        end

        themepark:add_debug_info(a, object.tags)
        themepark:insert('roads', a)
    end
end)

themepark:add_proc('relation', function(object)
    if object.tags.type == 'route' and object.tags.route == 'road' then
        local a = { ref = object.tags.ref, network = object.tags.network }
        for i, member in ipairs(object.members) do
            if member.type == 'w' then
                a.member_id = member.ref
                a.member_position = id
                themepark:insert('road_routes', a)
            end
        end
    end
end)
