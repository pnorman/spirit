-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: buildings
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'buildings',
    ids_type = 'area',
    geom = 'polygon',
    columns = themepark:columns({
        { column = 'name', type = 'text' },
        { column = 'way_area', type = 'real' },
        { column = 'point', type = 'point' },
    }),
    indexes = {
        { method = 'gist', column = 'point' },
    }
}

themepark:add_proc('area', function(object, data)
    if object.tags.building and object.tags.building ~= 'no' and common.isarea(object.tags) then
        for g in object.as_area():geometries() do
            local g_transform = g:transform(3857)
            local name = object.tags.name
            local a = { name = name, way_area = g_transform:area(), geom = g_transform }
            -- Only add points for buildings that need labels
            if name then
                a.point = g_transform:pole_of_inaccessibility()
            end
            themepark:add_debug_info(a, object.tags)
            themepark:insert('buildings', a)
        end
    end
end)

