-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: aerialways
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')
local aerialway_values = { 'cable_car', 'gondola', 'goods', 'chair_lift',
                           'drag_lift', 't-bar', 'j-bar', 'platter', 'rope_tow' }

local tags = {}

for _, value in ipairs(aerialway_values) do
    table.insert(tags, { key = 'aerialway', value = value, on = 'w' })
end

themepark:add_table{
    name = 'aerialways',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
    }),
    tags = tags,
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

local get_aerialway_value = osm2pgsql.make_check_values_func(aerialway_values)

-- ---------------------------------------------------------------------------

themepark:add_proc('way', function(object, data)
    local t = object.tags

    local aerialway = get_aerialway_value(t.aerialway)
    if aerialway then
        local a = {
            kind = aerialway,
            geom = object:as_linestring()
        }

        themepark:insert('aerialways', a, t)
    end
end)

-- ---------------------------------------------------------------------------
