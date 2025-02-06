-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: piers
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

local man_made_values = { 'pier', 'breakwater', 'groyne' }

themepark:add_table{
    name = 'pier_lines',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
    }),
    tags = {
        { key = 'man_made', values = man_made_values, on = 'w' },
    },
    tiles = {
        minzoom = 12,
    },
    expire = {
        { output = expire[12] },
        { output = expire[13] },
        { output = expire[14] }
    }
}

themepark:add_table{
    name = 'pier_polygons',
    ids_type = 'way',
    geom = 'polygon',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
    }),
    tags = {
        { key = 'man_made', values = man_made_values, on = 'a' },
    },
    tiles = {
        minzoom = 12,
    },
    expire = {
        { output = expire[12] },
        { output = expire[13] },
        { output = expire[14] }
    }
}

-- ---------------------------------------------------------------------------

themepark:add_proc('way', function(object, data)
    if object.is_closed then
        return
    end

    local t = object.tags
    local man_made = t.man_made

    if man_made == 'pier' or man_made == 'breakwater' or man_made == 'groyne' then
        local a = { kind = man_made }
        a.geom = object:as_linestring()
        themepark:insert('pier_lines', a, t)
    end
end)

themepark:add_proc('area', function(object, data)
    local t = object.tags
    local man_made = t.man_made

    if man_made == 'pier' or man_made == 'breakwater' or man_made == 'groyne' then
        local a = { kind = man_made }

        for sgeom in object:as_area():geometries() do
            a.geom = sgeom
            themepark:insert('pier_polygons', a, t)
        end
    end
end)

-- ---------------------------------------------------------------------------
