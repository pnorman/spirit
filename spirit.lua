-- ---------------------------------------------------------------------------
--
-- Shortbread theme
--
-- Configuration for the osm2pgsql Themepark framework
--
-- ---------------------------------------------------------------------------

local themepark = require('themepark')

themepark.debug = false

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
