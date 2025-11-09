-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: leisure
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'leisure',
    ids_type = 'area',
    geom = 'multipolygon',
    columns = themepark:columns({
        { column = 'names', type = 'jsonb' },
        { column = 'leisure', type = 'text' },
        { column = 'way_area', type = 'real' },
        { column = 'point', type = 'point' },
    }),
    indexes = {
        { method = 'gist', column = 'point' },
    }
}

themepark:add_proc('area', function(object, data)
    local leisure
    if object.tags.leisure == 'park' then
        leisure = 'park'
    elseif object.tags.natural == 'stadium' then
        leisure = 'stadium'
    elseif object.tags.natural == 'playground' then
        leisure = 'playground'
    end

    if leisure ~= nil then
        local g_transform = object:as_area():transform(3857)
        local names = common.get_names(object.tags)
        local a = {
            names = names,
            leisure = leisure,
            way_area = g_transform:area(),
            geom = g_transform }

        if next(names) ~= nil then
            a.point = g_transform:pole_of_inaccessibility()
        end
        themepark:add_debug_info(a, object.tags)
        themepark:insert('leisure', a)
    end
end)
