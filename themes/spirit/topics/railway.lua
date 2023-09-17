-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: railway
--
-- ---------------------------------------------------------------------------

require ('themes.spirit.common')

local themepark, theme, cfg = ...

themepark:add_table{
    name = 'railways',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'railway', type = 'text' },
        { column = 'minor', type = 'boolean' },
        { column = 'bridge', type = 'boolean' },
        { column = 'tunnel', type = 'boolean' },
        { column = 'layer', type = 'smallint' },
        { column = 'z_order', type = 'smallint' },
    }),
}

local ssy = {'spur', 'siding', 'yard'}
themepark:add_proc('way', function(object, data)
    if object.tags.railway == 'rail' and not isarea(object.tags) then
        local a = { railway = object.tags.railway,
                    layer = layer(object.tags.layer),
                    z_order = z_order(object.tags),
                    geom = object.as_linestring() }
        if contains(ssy, object.tags.service) then
            a.minor = true
        end
        if object.tags.bridge and object.tags.bridge ~= 'no' then
            a.bridge = true
        end
        if object.tags.tunnel and object.tags.tunnel ~= 'no' then
            a.tunnel = true
        end

        themepark:add_debug_info(a, object.tags)
        themepark:insert('railways', a)
    end
end)


