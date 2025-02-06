-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: public_transport
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

themepark:add_table{
    name = 'public_transport',
    ids_type = 'any',
    geom = 'point',
    columns = themepark:columns('core/name', {
        { column = 'kind', type = 'text', not_null = true },
        { column = 'minzoom', type = 'int', tiles = 'minzoom' }
    }),
    tags = {
        { key = 'aerialway', values = { 'ferry_terminal', 'station' }, on = 'na' },
        { key = 'aeroway', values = { 'aerodrome', 'helipad' }, on = 'na' },
        { key = 'amenity', value = 'bus_station', on = 'na' },
        { key = 'highway', value = 'bus_stop', on = 'na' },
        { key = 'railway', values = { 'station', 'halt', 'tram_stop' }, on = 'na' },
    },
    tiles = {
        minzoom = 11,
    },
    expire = {
        { output = expire[11] },
        { output = expire[12] },
        { output = expire[13] },
        { output = expire[14] }
    }

}

-- ---------------------------------------------------------------------------

local get_attributes = function(object)
    local t = object.tags
    local a = {}

    if t.aeroway then
        if t.aeroway == 'aerodrome' then
            a.kind = 'aerodrome'
            a.minzoom = 11
        elseif t.aeroway == 'helipad' then
            a.kind = 'helipad'
            a.minzoom = 13
        else
            return  nil
        end
    elseif t.railway then
        if t.railway == 'station' then
            a.kind = 'station'
            a.minzoom = 13
        elseif t.railway == 'halt' then
            a.kind = 'halt'
            a.minzoom = 13
        elseif t.railway == 'tram_stop' then
            a.kind = 'tram_stop'
            a.minzoom = 14
        else
            return  nil
        end
    elseif t.amenity and t.amenity == 'bus_station' then
        a.kind = 'bus_station'
        a.minzoom = 13
    elseif t.highway and t.highway == 'bus_stop' then
        a.kind = 'bus_stop'
        a.minzoom = 14
    elseif t.aerialway then
        if t.aerialway == 'ferry_terminal' then
            a.kind = 'ferry_terminal'
            a.minzoom = 12
        elseif t.aerialway == 'station' then
            a.kind = 'aerialway_station'
            a.minzoom = 13
        else
            return  nil
        end
    else
        return nil
    end

    themepark.themes.core.add_name(a, object)

    return a
end

-- ---------------------------------------------------------------------------

themepark:add_proc('node', function(object, data)
    local a = get_attributes(object)
    if a then
        a.geom = object:as_point()
        themepark:insert('public_transport', a, object.tags)
    end
end)

themepark:add_proc('area', function(object, data)
    local a = get_attributes(object)
    if a then
        a.geom = object:as_area():centroid()
        themepark:insert('public_transport', a, object.tags)
    end
end)

-- ---------------------------------------------------------------------------
