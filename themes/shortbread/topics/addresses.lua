-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: addresses
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

themepark:add_table{
    name = 'addresses',
    ids_type = 'any',
    geom = 'point',
    columns = themepark:columns({
        { column = 'housename', type = 'text' },
        { column = 'housenumber', type = 'text' },
    }),
    tags = {
        { key = 'addr:housename' },
        { key = 'addr:housenumber' },
    },
    tiles = {
        minzoom = 14,
    },
    expire = expire.shortbread(14, 14, 'addresses', 'full-area')
}

-- ---------------------------------------------------------------------------

local function process(t)
    if not t['addr:housenumber'] and not t['addr:housename'] then
        return nil
    end

    return {
        housenumber = t['addr:housenumber'],
        housename = t['addr:housename'],
    }
end

-- ---------------------------------------------------------------------------

themepark:add_proc('node', function(object, data)
    -- Shortbread spec: Ignore addresses that are already in "pois" layer.
    if data.shortbread_in_pois then
        return
    end

    local a = process(object.tags)
    if a then
        a.geom = object:as_point()
        themepark:insert('addresses', a, object.tags)
    end
end)

themepark:add_proc('way', function(object, data)
    -- Shortbread spec: Ignore addresses that are already in "pois" layer.
    if data.shortbread_in_pois or not object.is_closed then
        return
    end

    local a = process(object.tags)
    if a then
        a.geom = object:as_polygon():pole_of_inaccessibility()
        themepark:insert('addresses', a, object.tags)
    end
end)

themepark:add_proc('relation', function(object, data)
    -- Shortbread spec: Ignore addresses that are already in "pois" layer.
    if data.shortbread_in_pois then
        return
    end

    local a = process(object.tags)
    if a then
        for sgeom in object:as_multipolygon():geometries() do
            a.geom = sgeom:pole_of_inaccessibility()
            themepark:insert('addresses', a, object.tags)
        end
    end
end)

-- ---------------------------------------------------------------------------
