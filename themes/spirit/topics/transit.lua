-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: transit
--
-- ---------------------------------------------------------------------------

local common = require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'transit',
    ids_type = 'any',
    way_area, 'real',
    geom = 'point',
    columns = themepark:columns({
        { column = 'names', type = 'jsonb' },
        { column = 'station', type = 'boolean' },
        { column = 'mode', type = 'text' },
        { column = 'way_area', type = 'real' },
    }),
}

themepark:add_proc('node', function(object, data)
    local mode
    local station
    if object.tags.aeroway == 'aerodrome' then
        mode = 'airplane'
        station = true
    elseif (object.tags.railway == 'station' and object.tags.station == 'subway')
        or (object.tags.public_transport == 'station' and object.tags.subway == 'yes') then
        mode = 'subway'
        station = true
    elseif object.tags.highway == 'tram_stop' or (object.tags.public_transport == 'platform' and object.tags.tram == 'yes') then
        mode = 'tram'
        station = false
    elseif object.tags.highway == 'bus_stop'
        or (object.tags.public_transport == 'platform' and object.tags.bus == 'yes') then
        mode = 'bus'
        station = false
    elseif object.tags.highway == 'bus_station'
        or (object.tags.public_transport == 'station' and object.tags.bus == 'yes') then
        mode = 'bus'
        station = true
    end

    if mode ~= nil then
        local a = {
            geom = object:as_point(),
            mode = mode,
            station = station,
            names = common.get_names(object.tags) }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('transit', a)
    end
end)

themepark:add_proc('area', function(object, data)
    local mode
    local station
    -- The logic here is similar to node handling, but differs as some tagging is node-only
    if object.tags.aeroway == 'aerodrome' then
        mode = 'airplane'
        station = true
    elseif (object.tags.railway == 'station' and object.tags.station == 'subway')
        or (object.tags.public_transport == 'station' and object.tags.subway == 'yes') then
        mode = 'subway'
        station = true
    elseif object.tags.highway == 'tram_stop' or (object.tags.public_transport == 'platform' and object.tags.tram == 'yes') then
        mode = 'tram'
        station = false
    elseif object.tags.highway == 'bus_station'
        or (object.tags.public_transport == 'station' and object.tags.bus == 'yes') then
        mode = 'bus'
        station = true
    end

    if mode ~= nil then
        local g = object:as_area():transform(3857)
        local a = {
            geom = g:pole_of_inaccessibility(),
            way_area = g:area(),
            mode = mode,
            station = station,
            names = common.get_names(object.tags) }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('transit', a)
    end
end)
