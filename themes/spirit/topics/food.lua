-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: food
--
-- ---------------------------------------------------------------------------

require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'food',
    ids_type = 'any',
    geom = 'multipolygon',
    columns = themepark:columns({
        { column = 'name', type = 'text' },
        { column = 'food', type = 'text' },
        { column = 'way_area', type = 'real' },
        { column = 'point', type = 'point' },
    }),
    indexes = {
        { method = 'gist', column = 'point' },
    }
}

local amenities = { 'bar', 'biergarten', 'cafe', 'fast_food', 'food_court', 'ice_cream', 'pub', 'restaurant' }

themepark:add_proc('node', function(object, data)
    if object.tags.amenity and contains(amenities, object.tags.amenity) then
        local a = {
            point = object:as_point(),
            name = object.tags.name,
            food = object.tags.amenity }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('food', a)
    end
end)

themepark:add_proc('area', function(object, data)
    if object.tags.amenity and contains(amenities, object.tags.amenity) and isarea(object.tags) then
        local g_transform = object:as_area():transform(3857)
        local a = {
            geom = g_transform,
            point = g_transform:pole_of_inaccessibility(),
            way_area = g_transform:area(),
            name = object.tags.name,
            food = object.tags.amenity }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('food', a)
    end
end)
