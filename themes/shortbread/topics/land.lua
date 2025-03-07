-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: land
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

-- ---------------------------------------------------------------------------

local landuse_lookup = {
    forest = 7,
    grass = 11,
    meadow = 11,
    orchard = 11,
    vineyard = 11,
    allotments = 11,
    cemetery = 13,

    village_green = 11,
    recreation_ground = 11,
    greenhouse_horticulture = 11,
    plant_nursery = 11,

    residential = 10,
    industrial = 10,
    commercial = 10,
    garages = 10,
    retail = 10,
    railway = 10,
    landfill = 10,

    quarry = 11,

    brownfield = 10,
    greenfield = 10,
    farmyard = 10,
    farmland = 10,
}

local natural_lookup = {
    sand = 10,
    beach = 10,
    heath = 11,
    scrub = 11,
    grassland = 11,
    bare_rock = 11,
    scree = 11,
    shingle = 11,
}

local wetland_values = { "swamp", "bog", "string_bog", "wet_meadow", "marsh" }

local leisure_values = { "golf_course", "park", "garden", "playground", "miniature_golf" }

-- ---------------------------------------------------------------------------

local landuse_values = {}
for k, _ in pairs(landuse_lookup) do
    table.insert(landuse_values, k)
end

local natural_values = {}
for k, _ in pairs(natural_lookup) do
    table.insert(natural_values, k)
end

local check_wetland = osm2pgsql.make_check_values_func(wetland_values)

local check_leisure = osm2pgsql.make_check_values_func(leisure_values)

-- ---------------------------------------------------------------------------

themepark:add_table{
    name = 'land',
    ids_type = 'area',
    geom = 'geometry',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
        { column = 'minzoom', type = 'int', not_null = true, tiles = 'minzoom' },
    }),
    tags = {
        { key = 'landuse', values = landuse_values, on = 'a' },
        { key = 'leisure', values = leisure_values, on = 'a' },
        { key = 'natural', values = natural_values, on = 'a' },
        { key = 'wetland', values = wetland_values, on = 'a' },
    },
    tiles = {
        minzoom = 7
    },
    expire = expire.shortbread(7, 14, 'land', 'full-area')
}

-- ---------------------------------------------------------------------------

themepark:add_proc('area', function(object, data)
    local t = object.tags
    local a = { geom = object:as_area() }

    local minzoom = landuse_lookup[t.landuse]
    if minzoom then
        a.kind = t.landuse
        a.minzoom = minzoom
    elseif t.natural == 'wood' then
        a.kind = 'forest'
        a.minzoom = 7
    elseif t.amenity == 'grave_yard' then
        a.kind = 'grave_yard'
        a.minzoom = 13
    else
        minzoom = natural_lookup[t.natural]
        if minzoom then
            a.kind = t.natural
            a.minzoom = minzoom
        else
            local wetland = check_wetland(t.wetland)
            if wetland then
                a.kind = wetland
                a.minzoom = 11
            else
                local leisure = check_leisure(t.leisure)
                if leisure then
                    a.kind = leisure
                    a.minzoom = 11
                end
            end
        end
    end

    if a.kind then
        themepark:insert('land', a, t)
    end
end)

-- ---------------------------------------------------------------------------
