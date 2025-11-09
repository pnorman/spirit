-- ---------------------------------------------------------------------------
--
-- Shortbread theme
--
-- Configuration for the osm2pgsql Themepark framework
--
-- ---------------------------------------------------------------------------

local themepark = require('themepark')

themepark.debug = false

script_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
if script_path ~= nil then
    -- osm2pgsql was told to load foo/shortbread.lua, so we need to add foo to the path
    package.path = script_path.."?.lua;"..package.path
end

-- Tell themepark where the themes are
themepark:add_theme_dir('themes')

-- --------------------------------------------------------------------------

themepark:add_topic('spirit/buildings')
themepark:add_topic('spirit/roads')
themepark:add_topic('spirit/railway')
themepark:add_topic('spirit/aeroway')

themepark:add_topic('core/layer')

themepark:add_topic('shortbread/aerialways')
themepark:add_topic('shortbread/boundary_labels')
themepark:add_topic('shortbread/bridges')
themepark:add_topic('shortbread/dams')
themepark:add_topic('shortbread/ferries')
themepark:add_topic('shortbread/land')
themepark:add_topic('shortbread/piers')
themepark:add_topic('shortbread/places')
themepark:add_topic('shortbread/public_transport')
themepark:add_topic('shortbread/sites')
themepark:add_topic('shortbread/water')

themepark:add_topic('shortbread/pois')
-- Must be after "pois" layer, because as per Shortbread spec addresses that
-- are already in "pois" should not be in the "addresses" layer.
themepark:add_topic('shortbread/addresses')
themepark:add_topic('shortbread/boundaries')
themepark:add_topic('shortbread/streets')

-- ---------------------------------------------------------------------------
