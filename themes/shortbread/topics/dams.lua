-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: dams
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

themepark:add_table{
    name = 'dam_lines',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
    }),
    tags = {
        { key = 'waterway', value = 'dam', on = 'w' },
    },
    tiles = {
        minzoom = 12,
    },
    expire = expire.shortbread(14, 14, 'dam_lines', 'full-area')
}

themepark:add_table{
    name = 'dam_polygons',
    ids_type = 'way',
    geom = 'polygon',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
    }),
    tags = {
        { key = 'waterway', value = 'dam', on = 'a' },
    },
    tiles = {
        minzoom = 12,
    },
    expire = expire.shortbread(12, 14, 'dam_polygons', 'full-area')
}

-- ---------------------------------------------------------------------------

themepark:add_proc('way', function(object, data)
    if object.is_closed then
        return
    end

    local t = object.tags
    local waterway = t.waterway

    if waterway == 'dam' then
        local a = { kind = waterway }
        a.geom = object:as_linestring()
        themepark:insert('dam_lines', a, t)
    end
end)

themepark:add_proc('area', function(object, data)
    local t = object.tags
    local waterway = t.waterway

    if waterway == 'dam' then
        local a = { kind = waterway }

        for sgeom in object:as_area():geometries() do
            a.geom = sgeom
            themepark:insert('dam_polygons', a, t)
        end
    end
end)

-- ---------------------------------------------------------------------------
