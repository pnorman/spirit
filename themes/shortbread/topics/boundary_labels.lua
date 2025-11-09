-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: boundaries
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')
local common = require('themes.spirit.common')

themepark:add_table{
    name = 'boundary_labels',
    ids_type = 'relation',
    geom = 'point',
    columns = themepark:columns({
        { column = 'names', type = 'jsonb' },
        { column = 'admin_level', type = 'int' },
        { column = 'way_area', type = 'real' },
        { column = 'minzoom', type = 'int', tiles = 'minzoom' },
    }),
    tags = {
        { key = 'admin_level', values = { '2', '4' }, on = 'r' },
        { key = 'boundary', value = 'administrative', on = 'r' },
    },
    expire = expire.shortbread(0, 14, 'boundary_labels', 'full-area')
}

-- ---------------------------------------------------------------------------

themepark:add_proc('relation', function(object, data)
    local t = object.tags
    if t.boundary == 'administrative' then
        local admin_level = tonumber(t.admin_level)
        if admin_level == nil or admin_level > 4 or admin_level < 2 or admin_level == 3 then
            return
        end

        local mgeom = object:as_multipolygon()

        if mgeom then
            local a = { admin_level = admin_level,
                        names = common.get_names(object.tags) }

            local best_geom
            local best_area = 0
            for sgeom in mgeom:geometries() do
                local this_area = sgeom:spherical_area()
                if this_area > best_area then
                    best_area = this_area
                    best_geom = sgeom
                end
            end

            if best_geom then
                a.way_area = best_area

                if admin_level == 2 then
                    if a.way_area > 2000000 then
                        a.minzoom = 2
                    elseif a.way_area > 700000 then
                        a.minzoom = 3
                    elseif a.way_area > 100000 then
                        a.minzoom = 4
                    else
                        a.minzoom = 5
                    end
                else -- == 4
                    if a.way_area > 700000 then
                        a.minzoom = 3
                    elseif a.way_area > 100000 then
                        a.minzoom = 4
                    else
                        a.minzoom = 5
                    end
                end

                a.geom = best_geom:transform(3857):pole_of_inaccessibility()
                themepark:insert('boundary_labels', a, t)
            end
        end
    end
end)

-- ---------------------------------------------------------------------------
