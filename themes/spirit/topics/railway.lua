-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: railway
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local common = require('themes.spirit.common')
local expire = require('expire')

themepark:add_table{
    name = 'railways',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'railway', type = 'text' },
        { column = 'name', type = 'text' },
        { column = 'ref', type = 'text' },
        { column = 'minor', type = 'boolean' },
        { column = 'bridge', type = 'boolean' },
        { column = 'tunnel', type = 'boolean' },
        { column = 'layer', type = 'smallint' },
        { column = 'z_order', type = 'smallint' },
        { column = 'service', type = 'text' },
    }),
    expire = {
        { output = expire[10] },
        { output = expire[11] },
        { output = expire[12] },
        { output = expire[13] },
        { output = expire[14] }
    }
}

local z_order = {
 rail = 440
}


local ssy = {'spur', 'siding', 'yard'}
themepark:add_proc('way', function(object, data)
    local z = z_order[object.tags.railway]
    if z then
        local a = { name = object.tags.name,
                    ref = object.tags.ref,
                    railway = object.tags.railway,
                    service = object.tags.service,
                    layer = common.layer(object.tags.layer),
                    z_order = z,
                    geom = object:as_linestring() }
        if common.contains(ssy, object.tags.service) then
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


