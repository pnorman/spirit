-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: water
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...

-- ---------------------------------------------------------------------------

local waterway_values = { "river", "canal", "stream", "ditch" }

local bridge_values = {
    'yes', 'viaduct', 'boardwalk', 'cantilever', 'covered', 'low_water_crossing', 'movable', 'trestle'
}

local tunnel_values = { 'yes', 'building_passage' }

-- ---------------------------------------------------------------------------

themepark:add_table{
    name = 'water_areas',
    ids_type = 'area',
    geom = 'multipolygon',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
        { column = 'way_area', type = 'real' },
    }),
    tags = {
        { key = 'landuse', values = { 'basin', 'reservoir' }, on = 'a' },
        { key = 'natural', values = { 'water', 'glacier' }, on = 'a' },
        { key = 'water', value = 'river', on = 'a' },
        { key = 'waterway', values = { 'riverbank', 'dock', 'canal' }, on = 'a' },
    },
    tiles = {
        minzoom = 5
    }
}

themepark:add_table{
    name = 'water_area_labels',
    ids_type = 'area',
    geom = 'point',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text', not_null = true },
        { column = 'way_area', type = 'real' },
    }),
    tiles = {
        minzoom = 5,
        order_by = 'way_area',
        order_dir = 'desc',
    }
}

themepark:add_table{
    name = 'water_lines',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'kind', type = 'text', not_null = true },
        { column = 'tunnel', type = 'bool', not_null = true },
        { column = 'bridge', type = 'bool', not_null = true },
        { column = 'layer', type = 'int', not_null = true },
        { column = 'minzoom', type = 'int', not_null = true, tiles = 'minzoom' },
    }),
    tags = {
        { key = 'bridge', values = bridge_values, on = 'w' },
        { key = 'covered', value = 'yes', on = 'w' },
        { key = 'tunnel', values = tunnel_values, on = 'w' },
        { key = 'waterway', values = waterway_values, on = 'w' },
    },
    tiles = {
        minzoom = 9,
        order_by = 'layer',
        order_dir = 'asc',
    }
}

themepark:add_table{
    name = 'water_lines_labels',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text', not_null = true },
        { column = 'minzoom', type = 'int', not_null = true },
    }),
    tiles = {
        minzoom = 12,
    }
}

-- ---------------------------------------------------------------------------

local check_waterway = osm2pgsql.make_check_values_func(waterway_values)

local round = function(value)
    return math.floor(value + 0.5)
end

local get_bridge_value = osm2pgsql.make_check_values_func(bridge_values, false)

-- ---------------------------------------------------------------------------

themepark:add_proc('way', function(object, data)
    local t = object.tags
    local waterway = t.waterway
    if check_waterway(waterway) then
        local a = {
            kind = waterway,
            geom = object:as_linestring(),
            layer = data.core.layer,
            bridge = get_bridge_value(t.bridge),
            tunnel = false,
        }

        if t.tunnel == 'yes' or t.tunnel == 'building_passage' or t.covered == 'yes' then
            a.tunnel = true
        end

        if a.kind == 'stream' or a.kind == 'ditch' then
            a.minzoom = 14
        else
            a.minzoom = 9
        end

        themepark:add_debug_info(a, t)
        themepark:insert('water_lines', a)

        if themepark.themes.core.add_name(a, object) then
            themepark:insert('water_lines_labels', a)
        end
    end
end)

themepark:add_proc('area', function(object, data)
    local t = object.tags
    local kind

    if t.natural == 'glacier' then
        kind = 'glacier'
    elseif t.natural == 'water' then
        if t.water == 'river' then
            kind = 'river'
        else
            kind = 'water'
        end
    elseif t.waterway == 'riverbank' then
        kind = 'river'
    elseif t.waterway == 'dock' or t.waterway == 'canal' then
        kind = t.waterway
    elseif t.landuse == 'basin' or t.landuse == 'reservoir' then
        kind = t.landuse
    end

    if not kind then
        return
    end

    local g = object.as_area():transform(3857)
    local a = {
        kind = kind,
        way_area = round(g:area()),
        geom = g
    }
    themepark:insert('water_areas', a)

    if themepark.themes.core.add_name(a, object) then
        a.geom = g:pole_of_inaccessibility()
        themepark:insert('water_area_labels', a)
    end
end)

-- ---------------------------------------------------------------------------
