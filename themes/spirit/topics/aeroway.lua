-- ---------------------------------------------------------------------------
--
-- Theme: spirit
-- Topic: aeroway
--
-- Airports are already present in the transit layer, so this is just more airport-focused stuff
--
-- ---------------------------------------------------------------------------


local themepark, theme, cfg = ...
local common = require('themes.spirit.common')
local expire = require('expire')

themepark:add_table{
    name = 'aeroways',
    ids_type = 'way',
    geom = 'linestring',
    columns = themepark:columns({
        { column = 'ref', type = 'text' },
        { column = 'aeroway', type = 'text' },
    }),
    expire = expire.shortbread(11, 14, 'streets', 'boundary-only')
}

themepark:add_proc('way', function(object, data)
    if object.tags.aeroway == 'runway'
       or object.tags.aeroway == 'taxiway' then
        local a = { aeroway = object.tags.aeroway,
                    ref = object.tags.ref,
                    geom = object:as_linestring() }
        themepark:add_debug_info(a, object.tags)
        themepark:insert('aeroways', a)
    end
end)
