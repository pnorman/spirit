-- ---------------------------------------------------------------------------
--
-- Street Spirit theme
--
-- Configuration for the osm2pgsql Themepark framework
--
-- ---------------------------------------------------------------------------

local themepark = require('themepark')

themepark.debug = false

-- Tell themepark where the spirit themes are in case it's not the current working directory
local spirit_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")

if spirit_path ~= nil then
    -- theme_path[1] is the osm2pgsql-themepark location, but it doesn't pick up the spirit location
    themepark.theme_path[2] = spirit_path..'themes/'
end

themepark:add_topic('spirit/buildings')
themepark:add_topic('spirit/water')
themepark:add_topic('spirit/education')
themepark:add_topic('spirit/food')
themepark:add_topic('spirit/leisure')
themepark:add_topic('spirit/vegetation')
themepark:add_topic('spirit/landuse')
themepark:add_topic('spirit/roads')
themepark:add_topic('spirit/railway')
themepark:add_topic('spirit/transit')
themepark:add_topic('spirit/aeroway')
themepark:add_topic('spirit/places')
themepark:add_topic('spirit/admin')
