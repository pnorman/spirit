-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: education
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'education',
    ids_type = 'any',
    geom = 'multipolygon',
    columns = themepark:columns({
        { column = 'names', type = 'jsonb' },
        { column = 'education', type = 'text' },
        { column = 'way_area', type = 'real' },
        { column = 'point', type = 'point' },
    }),
    indexes = {
        { method = 'gist', column = 'point' },
    }
}

themepark:add_proc('node', function(object, data)
    local education
    if object.tags.amenity == 'school' then
        education = 'school'
    elseif object.tags.amenity == 'kindergarten' then
        education = 'kindergarten'
    elseif object.tags.amenity == 'university' then
        education = 'university'
    elseif object.tags.amenity == 'college' then
        education = 'college'
    end
    if education ~= nil then
        local a = {
            point = object:as_point(),
            names = common.get_names(object.tags),
            education = education }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('education', a)
    end
end)

themepark:add_proc('area', function(object, data)
    local education
    if object.tags.amenity == 'school' then
        education = 'school'
    elseif object.tags.amenity == 'kindergarten' then
        education = 'kindergarten'
    elseif object.tags.amenity == 'university' then
        education = 'university'
    elseif object.tags.amenity == 'college' then
        education = 'college'
    end
    if education ~= nil then
        local g_transform = object:as_area():transform(3857)
        local a = {
            geom = g_transform,
            point = g_transform:pole_of_inaccessibility(),
            way_area = g_transform:area(),
            names = common.get_names(object.tags),
            education = education }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('education', a)
    end
end)
