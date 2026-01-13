-- This is a very simple Lua config for the Flex output
-- which only stores the geometries (and tags as jsonb)
-- for use with Underpass-API to mimic Overpass

-- osm2pgsql -d spirit -O flex -S geometries-alone.lua data/alsace.osm.pbf

-- For Europe or planet, add
-- --flat-nodes FILE  to use the flat file for nodes
-- 

-- CREATE INDEX nodes_tags_idx ON nodes_geom USING GIN (tags);

local tables = {}

tables.nodes_geom = osm2pgsql.define_table({
    name = 'nodes_geom',
    ids = { type = 'node', id_column = 'id', create_index='unique'  },
    columns = {
        { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'point', projection = 3857, not_null = true  }
}})

tables.ways_geom = osm2pgsql.define_table({
    name = 'ways_geom',
    ids = { type = 'way', id_column = 'id', create_index='unique' },
    columns = {
        { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'geometry', projection = 3857, not_null = true },
        { column = 'area', type = 'real' }
}})

tables.rels_geom = osm2pgsql.define_table({
    name = 'rels_geom',
    ids = { type = 'relation', id_column = 'id', create_index='unique' },
    columns = {
        { column = 'tags', type = 'jsonb' },
        { column = 'geom', type = 'geometry', projection = 3857, not_null = true },
        { column = 'area', type = 'real' }
}})


-- Helper function that looks at the tags and decides if this is possibly an area
local function has_area_tags(tags)
    if tags.area == 'yes' or tags.area == 'true' or tags.area == '1' then
        return true
    end
    if tags.area == 'no' or tags.area == 'false' or tags.area == '0'  then
        return false
    end

    return tags.aeroway
        or tags.amenity
        or tags.building
        or tags.harbour
        or tags.historic
        or tags.landuse
        or tags.leisure
        or tags.man_made
        or tags.military
        or tags.natural
        or tags.office
        or tags.place
        or tags.power
        or tags.public_transport
        or tags.shop
        or tags.sport
        or tags.tourism
        or tags.water
        or tags.waterway
        or tags.wetland
        or tags['abandoned:aeroway']
        or tags['abandoned:amenity']
        or tags['abandoned:building']
        or tags['abandoned:landuse']
        or tags['abandoned:power']
        or tags['area:highway']
end

-- Store geometry of nodes (so that they can be indexed)
function osm2pgsql.process_node(object)
    tables.nodes_geom:insert({
        tags = object.tags,
        geom = object:as_point()
    })
end


function osm2pgsql.process_way(object)

    -- A closed way that also has the right tags for an area is a polygon.
    if object.is_closed and has_area_tags(object.tags) then
        -- Creating the polygon geometry takes time, so we do it once here
        -- and later store it in the table and use it to calculate the area.
        local geom = object:as_polygon()
        tables.ways_geom:insert({
            tags = object.tags,
            geom = geom,
            area = geom:spherical_area()  -- calculate "real" area in spheroid
        })
    else
        -- Store way as line
        tables.ways_geom:insert({
            tags = object.tags,
            geom = object:as_linestring()
        })
    end
end

function osm2pgsql.process_relation(object)

    local relation_type = object:grab_tag('type')

    -- Store multipolygon and boundary relations as multipolygons, with their area
    if relation_type == 'multipolygon' or relation_type == 'boundary' then
        local geom = object:as_multipolygon()
        tables.rels_geom:insert({
            tags = object.tags,
            geom = geom,
            area = geom:spherical_area()
        })
    else
    -- Store other relations as geometryCollection
        tables.rels_geom:insert({
            tags = object.tags,
            geom = object:as_geometrycollection()
        })
    end
end

