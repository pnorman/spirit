-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: streets
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

themepark:add_table{
    name = 'street_polygons',
    ids_type = 'way',
    geom = 'polygon',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
        { column = 'rail', type = 'bool' },
        { column = 'tunnel', type = 'bool' },
        { column = 'bridge', type = 'bool' },
        { column = 'surface', type = 'text' },
        { column = 'z_order', type = 'int' },
    }),
    tiles = {
        minzoom = 11,
        order_by = 'z_order',
        order_dir = 'desc',
    },
    expire = expire.shortbread(11, 14, 'street_polygons', 'full-area')
}

themepark:add_table{
    name = 'streets_polygons_labels',
    ids_type = 'area',
    geom = 'point',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text', not_null = true },
    }),
    tiles = {
        minzoom = 11
    },
    expire = expire.shortbread(11, 14, 'streets_polygons_labels', 'full-area')
}

themepark:add_table{
    name = 'streets_labels_points',
    ids_type = 'node',
    geom = 'point',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text' },
        { column = 'ref', type = 'text' },
    }),
    tiles = {
        minzoom = 12,
    },
    expire = expire.shortbread(12, 14, 'streets_labels_points', 'full-area')
}

-- ---------------------------------------------------------------------------

local Z_STEP_PER_LAYER = 100

local highway_lookup = {
--  highway tag          z  minzoom
    motorway        = { 34,  5 },
    trunk           = { 33,  6 },
    primary         = { 32,  8 },
    secondary       = { 31,  9 },
    tertiary        = { 30, 10 },

    unclassified    = { 20, 12 },
    residential     = { 20, 12 },
    busway          = { 20, 12 },
    busway_guideway = { 20, 12 },
    road            = { 20, 12 },

    tertiary_link   = { 10, 12 },
    secondary_link  = { 10, 12 },
    primary_link    = { 10, 12 },
    trunk_link      = { 10, 12 },
    motorway_link   = { 10, 12 },

    living_street   = {  4, 13 },
    pedestrian      = {  4, 13 },

    service         = {  3, 13 },
    track           = {  3, 13 },

    footway         = {  2, 13 },
    path            = {  2, 13 },
    cycleway        = {  2, 13 },
    bridleway       = {  2, 13 },

    steps           = {  1, 13 },
    platform        = {  1, 13 },
}

local railway_lookup = {
    rail            = { 52,  8 },
    narrow_gauge    = { 51,  8 },
    tram            = { 51, 10 },
    light_rail      = { 51, 10 },
    funicular       = { 51, 10 },
    subway          = { 51, 10 },
    monorail        = { 51, 10 },
}

local aeroway_lookup = {
    runway  = 11,
    taxiway = 13,
}

local as_bool = function(value)
    return value == 'yes' or value == 'true' or value == '1'
end

local set_ref_attributes = function(a, t)
    if not t.ref then
        return
    end

    local refs = {}
    local rows = 0
    local cols = 0

    for word in string.gmatch(t.ref, "([^;]+);?") do
        word = word:gsub('^[%s]+', '', 1):gsub('[%s]+$', '', 1)
        rows = rows + 1
        cols = math.max(cols, string.len(word))
        table.insert(refs, word)
    end

    a.ref = table.concat(refs, '\n')
    a.ref_rows = rows
    a.ref_cols = cols
end

-- ---------------------------------------------------------------------------

themepark:add_proc('node', function(object, data)
    local t = object.tags

    if t.highway and t.highway == 'motorway_junction' then
        local a = {
            kind = t.highway,
            ref = t.ref,
            geom = object:as_point()
        }
        themepark.themes.core.add_name(a, object)
        themepark:insert('streets_labels_points', a, t)
    end
end)

local process_as_area = function(object, data)
    if not object.is_closed then
        return
    end

    local t = object.tags
    local a = {
        layer = data.core.layer,
    }
    a.z_order = Z_STEP_PER_LAYER * a.layer

    if t.highway == 'pedestrian' or t.highway == 'service' then
        a.kind = t.highway
    elseif t.aeroway == 'runway' or t.aeroway == 'taxiway' then
        a.kind = t.aeroway
    else
        return
    end

    a.surface = t.surface

    a.tunnel = as_bool(t.tunnel) or t.tunnel == 'building_passage' or t.covered == 'yes'
    a.bridge = as_bool(t.bridge)

    a.geom = object:as_polygon():transform(3857)
    local has_name = themepark.themes.core.add_name(a, object)
    themepark:insert('street_polygons', a, t)

    if has_name then
        a.geom = a.geom:pole_of_inaccessibility()
        themepark:insert('streets_polygons_labels', a, t)
    end
end

themepark:add_proc('way', function(object, data)
    local t = object.tags
    if t.area == 'yes' then
        process_as_area(object, data)
        return
    end
end)

-- ---------------------------------------------------------------------------
