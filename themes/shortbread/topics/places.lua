-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: places
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

-- ---------------------------------------------------------------------------

local place_types = {
    city              = { pop = 100000, minzoom =  6 },
    town              = { pop =   5000, minzoom =  7 },
    village           = { pop =    100, minzoom = 10 },
    hamlet            = { pop =     10, minzoom = 10 },
    suburb            = { pop =   1000, minzoom = 10 },
    quarter           = { pop =    500, minzoom = 10 },
    neighborhood      = { pop =    100, minzoom = 10 },
    isolated_dwelling = { pop =      5, minzoom = 10 },
    farm              = { pop =      5, minzoom = 10 },
    island            = { pop =      0, minzoom = 10 },
    locality          = { pop =      0, minzoom = 10 },
}

-- ---------------------------------------------------------------------------

local place_values = {}

for key, _ in pairs(place_types) do
    table.insert(place_values, key)
end

themepark:add_table{
    name = 'place_labels',
    ids_type = 'node',
    geom = 'point',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text', not_null = true },
        { column = 'population', type = 'int', not_null = true },
        { column = 'minzoom', type = 'int', not_null = true, tiles = 'minzoom' },
    }),
    tags = {
        { key = 'capital', on = 'n' },
        { key = 'place', on = 'n' },
        { key = 'population', on = 'n' },
    },
    tiles = {
        minzoom = 4,
        order_by = 'population',
        order_dir = 'desc',
    },
    expire = {
        { output = expire[10] },
        { output = expire[11] },
        { output = expire[12] },
        { output = expire[13] },
        { output = expire[14] }
    }
}

-- ---------------------------------------------------------------------------

themepark:add_proc('node', function(object, data)
    local t = object.tags
    if not t.place then
        return
    end

    local pt = place_types[t.place]
    if pt == nil then
        return
    end

    local a = {
        kind = t.place,
        population = tonumber(t.population) or pt.pop,
        minzoom = pt.minzoom,
        geom = object:as_point()
    }

    if t.capital == 'yes' then
        if t.place == 'city' or t.place == 'town' or t.place == 'village' or t.place == 'hamlet' then
            a.kind = 'capital'
            a.minzoom = 4
        end
    elseif t.capital == '4' then
        if t.place == 'city' or t.place == 'town' or t.place == 'village' or t.place == 'hamlet' then
            a.kind = 'state_capital'
            a.minzoom = 4
        end
    end

    themepark.themes.core.add_name(a, object)
    themepark:insert('place_labels', a, t)
end)

-- ---------------------------------------------------------------------------
