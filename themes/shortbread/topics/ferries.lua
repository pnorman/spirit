-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: ferries
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')
local common = require('themes.spirit.common')

themepark:add_table{
    name = 'ferries',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'names', type = 'jsonb' },
        { column = 'kind', type = 'text', not_null = true },
        { column = 'minzoom', type = 'int', tiles = 'minzoom' },
    }),
    tags = {
        { key = 'route', value = 'ferry', on = 'w' },
        { key = 'motor_vehicle', on = 'w' },
    },
    tiles = {
        minzoom = 10,
    },
    expire = expire.shortbread(10, 14, 'ferries', 'full-area')
}

-- ---------------------------------------------------------------------------

themepark:add_proc('way', function(object, data)
    local t = object.tags

    if t.route == 'ferry' then
        local a = {
            kind = 'ferry',
            names = common.get_names(object.tags),
            geom = object:as_linestring()
        }

        if t.motor_vehicle and t.motor_vehicle ~= 'no' then
            a.minzoom = 10
        else
            a.minzoom = 12
        end

        themepark:insert('ferries', a, t)
    end
end)

-- ---------------------------------------------------------------------------
