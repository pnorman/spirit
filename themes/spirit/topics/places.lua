-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: places
--
-- ---------------------------------------------------------------------------

require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'settlements',
    ids_type = 'any',
    way_area, 'real',
    geom = 'point',
    columns = themepark:columns({
        { column = 'name', type = 'text' },
        { column = 'place', type = 'text' },
        { column = 'way_area', type = 'real' },
    }),
}

themepark:add_proc('node', function(object, data)
    local place
    if object.tags.place == 'city' then
        place = 'city'
    elseif object.tags.place == 'town' then
        place = 'town'
    elseif object.tags.place == 'village' then
        place = 'village'
    elseif object.tags.place == 'hamlet' then
        place = 'hamlet'
    elseif object.tags.place == 'isolated_dwelling' then
        place = 'isolated_dwelling'
    end

    if place ~= nil then
        local a = {
            geom = object:as_point(),
            place = place,
            name = object.tags.name }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('settlements', a)
    end
end)

themepark:add_proc('area', function(object, data)
    local place
    if object.tags.place == 'city' then
        place = 'city'
    elseif object.tags.place == 'town' then
        place = 'town'
    elseif object.tags.place == 'village' then
        place = 'village'
    elseif object.tags.place == 'hamlet' then
        place = 'hamlet'
    elseif object.tags.place == 'isolated_dwelling' then
        place = 'isolated_dwelling'
    end

    if place ~= nil and isarea(object.tags) then
        local g = object:as_area():transform(3857)
        local a = {
            geom = g:pole_of_inaccessibility(),
            way_area = g:area(),
            place = place,
            name = object.tags.name }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('settlements', a)
    end
end)
