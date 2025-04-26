-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: sites
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

-- ---------------------------------------------------------------------------

local amenity_values = { 'university', 'college', 'school', 'hospital',
                         'prison', 'parking', 'bicycle_parking' }

-- ---------------------------------------------------------------------------

themepark:add_table{
    name = 'sites',
    ids_type = 'area',
    geom = 'multipolygon',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text', not_null = true },
    }),
    tags = {
        { key = 'amenity', values = amenity_values, on = 'a' },
        { key = 'landuse', value = 'construction', on = 'a' },
        { key = 'leisure', value = 'sports_centre', on = 'a' },
        { key = 'military', value = 'danger_area', on = 'a' },
    },
    tiles = {
        minzoom = 14,
    },
    expire = expire.shortbread(14, 14, 'sites', 'full-area')
}

-- ---------------------------------------------------------------------------

local get_amenity_value = osm2pgsql.make_check_values_func(amenity_values)

-- ---------------------------------------------------------------------------

themepark:add_proc('area', function(object, data)
    local t = object.tags
    local a = {
        kind = get_amenity_value(t.amenity)
    }

    if not a.kind then
        if t.military == 'danger_area' then
            a.kind = 'danger_area'
        elseif t.leisure == 'sports_centre' then
            a.kind = 'sports_centre'
        elseif t.landuse == 'construction' then
            a.kind = 'construction'
        else
            return
        end
    end

    a.geom = object:as_area()
    themepark.themes.core.add_name(a, object)
    themepark:insert('sites', a, t)
end)

-- ---------------------------------------------------------------------------
