-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: water
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'water',
    ids_type = 'area',
    geom = 'multipolygon',
    columns = themepark:columns({
        { column = 'name', type = 'text' },
        { column = 'way_area', type = 'real' },
        { column = 'point', type = 'point' },
    }),
    indexes = {
        { method = 'gist', column = 'point' },
    }
}

themepark:add_table{
    name = 'waterways',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'name', type = 'text' },
        { column = 'waterway', type = 'text' },
    }),
}

themepark:add_proc('area', function(object, data)
    if (object.tags.natural == 'water' or object.tags.waterway == 'dock' or object.tags.waterway == 'basin' or object.tags.waterway == 'reservoir')
        then
        local g_transform = object:as_area():transform(3857)
        local name = object.tags.name
        local a = { name = name, way_area = g_transform:area(), geom = g_transform }
        -- Only add points for water areas that need labels
        if name then
            a.point = g_transform:pole_of_inaccessibility()
        end
        themepark:add_debug_info(a, object.tags)
        themepark:insert('water', a)
    end
end)

themepark:add_proc('way', function(object, data)
    if (object.tags.waterway == 'river'
        or object.tags.waterway == 'canal'
        or object.tags.waterway == 'stream'
        or object.tags.waterway == 'drain'
        or object.tags.waterway == 'ditch'
    ) then
        local a = { name = object.tags.name, waterway = object.tags.waterway,
                    geom = object:as_linestring() }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('waterways', a)
    end
end)
