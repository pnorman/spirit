-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: vegetation
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'vegetation',
    ids_type = 'area',
    geom = 'multipolygon',
    columns = themepark:columns({
        { column = 'name', type = 'text' },
        { column = 'vegetation', type = 'text' },
        { column = 'wetland', type = 'text' },
        { column = 'way_area', type = 'real' },
        { column = 'point', type = 'point' },
    }),
    indexes = {
        { method = 'gist', column = 'point' },
    }
}

themepark:add_proc('area', function(object, data)
    local vegetation
    local wetland
    if object.tags.natural == 'wood' or object.tags.landuse == 'forest' then
        vegetation = 'wood'
    elseif object.tags.natural == 'heath' then
        vegetation = 'heath'
    elseif object.tags.natural == 'scrub' then
        vegetation = 'scrub'
    elseif object.tags.natural == 'grassland' or object.tags.landuse == 'meadow' or     object.tags.landuse == 'grass' then
        vegetation = 'grass'
    elseif object.tags.natural == 'mud' then
        vegetation = 'wetland'
        wetland = 'mud'
    elseif object.tags.natural == 'wetland' then
        vegetation = 'wetland'
        wetland = object.tags.wetland
    end

    if vegetation ~= nil and common.isarea(object.tags) then
        local g_transform = object:as_area():transform(3857)
        local a = {
            name = object.tags.name,
            vegetation = vegetation,
            wetland = wetland,
            way_area = g_transform:area(),
            geom = g_transform }

        if object.tags.name then
            a.point = g_transform:pole_of_inaccessibility()
        end
        themepark:add_debug_info(a, object.tags)
        themepark:insert('vegetation', a)
    end
end)
