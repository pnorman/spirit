-- ---------------------------------------------------------------------------
--
-- Shortbread theme
--
-- Configuration for the osm2pgsql Themepark framework
--
-- ---------------------------------------------------------------------------

local themepark = require('themepark')

themepark.debug = false

themepark:add_topic('core/name-with-fallback', {
    keys = {
        name = { 'name', 'name:en', 'name:de' },
        name_de = { 'name:de', 'name', 'name:en' },
        name_en = { 'name:en', 'name', 'name:de' },
    }
})

-- --------------------------------------------------------------------------

-- Put spirit files above shortbread, because shortbread still does some stuff to objects that might cause problems.

themepark:add_topic('spirit/buildings')


themepark:add_topic('core/layer')

themepark:add_topic('shortbread_v1/aerialways')
themepark:add_topic('shortbread_v1/boundaries')
themepark:add_topic('shortbread_v1/boundary_labels')
themepark:add_topic('shortbread_v1/bridges')
themepark:add_topic('shortbread_v1/dams')
themepark:add_topic('shortbread_v1/ferries')
themepark:add_topic('shortbread_v1/land')
themepark:add_topic('shortbread_v1/piers')
themepark:add_topic('shortbread_v1/places')
themepark:add_topic('shortbread_v1/pois')
themepark:add_topic('shortbread_v1/public_transport')
themepark:add_topic('shortbread_v1/sites')
themepark:add_topic('shortbread_v1/streets')
themepark:add_topic('shortbread/water')

-- Must be after "pois" layer, because as per Shortbread spec addresses that
-- are already in "pois" should not be in the "addresses" layer.
themepark:add_topic('shortbread_v1/addresses')

-- ---------------------------------------------------------------------------
