-- ---------------------------------------------------------------------------
--
-- Street Spirit theme
--
-- Configuration for the osm2pgsql Themepark framework
--
-- ---------------------------------------------------------------------------

local themepark = require('themepark')

themepark.debug = false

script_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
if script_path ~= nil then
    -- osm2pgsql was told to load foo/spirit.lua, so we need to add foo to the path
    package.path = script_path.."?.lua;"..package.path
end

-- Tell themepark where the themes are
themepark:add_theme_dir('themes')

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
