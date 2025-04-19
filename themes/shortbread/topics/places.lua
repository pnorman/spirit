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
    ids_type = 'any',
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
    expire = expire.shortbread(4, 14, 'place_labels', 'full-area')
}

-- ---------------------------------------------------------------------------

local function place_columns(tags)
    if not tags.place then
        return nil
    end

    local place_type = place_types[tags.place]
    if not place_type then
        return nil
    end

    local attributes = {
        kind = tags.place,
        population = tonumber(tags.population) or place_type.pop,
        minzoom = place_type.minzoom
    }

    if tags.capital == 'yes' then
        if tags.place == 'city' or tags.place == 'town' or tags.place == 'village' or tags.place == 'hamlet' then
            attributes.kind = 'capital'
            attributes.minzoom = 4
        end
    elseif tags.capital == '4' then
        if tags.place == 'city' or tags.place == 'town' or tags.place == 'village' or tags.place == 'hamlet' then
            attributes.kind = 'state_capital'
            attributes.minzoom = 4
        end
    end
    return attributes
end

themepark:add_proc('node', function(object, data)
    local a = place_columns(object.tags)
    if not a then
        return
    end

    a.geom = object:as_point()

    themepark.themes.core.add_name(a, object)
    themepark:insert('place_labels', a, tags)
end)

themepark:add_proc('area', function(object, data)
    local a = place_columns(object.tags)
    if not a then
        return
    end

    a.geom = object:as_area():transform(3857):pole_of_inaccessibility()

    themepark.themes.core.add_name(a, object)
    themepark:insert('place_labels', a, tags)
end)
-- ---------------------------------------------------------------------------
