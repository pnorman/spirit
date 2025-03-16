-- ---------------------------------------------------------------------------
--
-- Theme: shortbread_v1
-- Topic: pois
--
-- ---------------------------------------------------------------------------

local themepark, theme, cfg = ...
local expire = require('expire')

themepark:add_table{
    name = 'pois',
    ids_type = 'any',
    geom = 'point',
    columns = themepark:columns('core/name', {
        { column = 'amenity', type = 'text' },
        { column = 'leisure', type = 'text' },
        { column = 'tourism', type = 'text' },
        { column = 'shop', type = 'text' },
        { column = 'man_made', type = 'text' },
        { column = 'historic', type = 'text' },
        { column = 'emergency', type = 'text' },
        { column = 'highway', type = 'text' },
        { column = 'office', type = 'text' },
        { column = 'housename', type = 'text' },
        { column = 'housenumber', type = 'text' },
        { column = 'cuisine', type = 'text' },
        { column = 'sport', type = 'text' },
        { column = 'vending', type = 'text' },
        { column = 'information', type = 'text' },
        { column = 'tower:type', type = 'text' },
        { column = 'religion', type = 'text' },
        { column = 'denomination', type = 'text' },
        { column = 'recycling:glass_bottles', type = 'bool' },
        { column = 'recycling:paper', type = 'bool' },
        { column = 'recycling:clothes', type = 'bool' },
        { column = 'recycling:scrap_metal', type = 'bool' },
        { column = 'atm', type = 'bool' },
    }),
    tags = {
    },
    tiles = {
        minzoom = 14,
    },
    expire = expire.shortbread(14, 14, 'pois', 'full-area')

}

-- ---------------------------------------------------------------------------

local get_value = {}

get_value.amenity = osm2pgsql.make_check_values_func({
    'police', 'fire_station', 'post_box', 'post_office', 'telephone', 'library',
    'townhall', 'courthouse', 'prison', 'embassy', 'community_centre',
    'nursing_home', 'arts_centre', 'grave_yard', 'marketplace', 'recycling',
    'university', 'school', 'college', 'public_building', 'pharmacy',
    'hospital', 'clinic', 'doctors', 'dentist', 'veterinary', 'theatre',
    'nightclub', 'cinema', 'restaurant', 'fast_food', 'cafe', 'pub', 'bar',
    'food_court', 'biergarten', 'shelter', 'car_rental', 'car_wash',
    'car_sharing', 'bicycle_rental', 'vending_machine', 'bank', 'atm',
    'toilets', 'bench', 'drinking_water', 'fountain', 'hunting_stand',
    'waste_basket', 'place_of_worship', 'playground', 'dog_park'
})

get_value.leisure = osm2pgsql.make_check_values_func({
    'sports_centre', 'pitch', 'swimming_pool', 'water_park', 'golf_course',
    'stadium', 'ice_rink',
})

get_value.tourism = osm2pgsql.make_check_values_func({
    'hotel', 'motel', 'bed_and_breakfast', 'guest_house', 'hostel', 'chalet',
    'camp_site', 'alpine_hut', 'caravan_site', 'information', 'picnic_site',
    'viewpoint', 'zoo', 'theme_park',
})

get_value.shop = osm2pgsql.make_check_values_func({
    'supermarket', 'bakery', 'kiosk', 'mall', 'department_store', 'general',
    'convenience', 'clothes', 'florist', 'chemist', 'books', 'butcher',
    'shoes', 'alcohol', 'beverages', 'optican', 'jewelry', 'gift', 'sports',
    'stationery', 'outdoor', 'mobile_phone', 'toys', 'newsagent', 'greengrocer',
    'beauty', 'video', 'car', 'bicycle', 'doityourself', 'hardware',
    'furniture', 'computer', 'garden_centre', 'hairdresser', 'travel_agency',
    'laundry', 'dry_cleaning',
})

get_value.man_made = osm2pgsql.make_check_values_func({
    'surveillance', 'tower', 'windmill', 'lighthouse', 'wastewater_plant',
    'water_well', 'watermill', 'water_works',
})

get_value.historic = osm2pgsql.make_check_values_func({
    'monument', 'memorial', 'artwork', 'castle', 'ruins', 'archaelogical_site',
    'wayside_cross', 'wayside_shrine', 'battlefield', 'fort',
})

get_value.emergency = osm2pgsql.make_check_values_func({
    'phone', 'fire_hydrant', 'defibrillator'
})

get_value.highway = osm2pgsql.make_check_values_func({
    'emergency_access_point'
})

get_value.office = osm2pgsql.make_check_values_func({
    'diplomatic'
})

-- ---------------------------------------------------------------------------

local add_extra_attributes = {}

add_extra_attributes.amenity = function(a, t)
    if t.amenity == 'vending_machine' then
        a.vending = t.vending
    elseif t.amenity == 'place_of_worship' then
        a.religion = t.religion
        a.denomination = t.denomination
    elseif t.amenity == 'restaurant' or t.amenity == 'fast_food' or
           t.amenity == 'pub' or t.amenity == 'bar' or t.amenity == 'cafe' then
        a.cuisine = t.cuisine
    elseif t.amenity == 'recycling' then
        a['recycling:glass_bottles'] = t['recycling:glass_bottles'] == 'yes'
        a['recycling:paper'] = t['recycling:paper'] == 'yes'
        a['recycling:clothes'] = t['recycling:clothes'] == 'yes'
        a['recycling:scrap_metal'] = t['recycling:scrap_metal'] == 'yes'
    elseif t.amenity == 'bank' then
        a.atm = t.atm == 'yes'
    end
end

add_extra_attributes.tourism = function(a, t)
    if t.tourism == 'information' then
        a.information = t.information
    end
end

add_extra_attributes.man_made = function(a, t)
    if t.man_made == 'tower' then
        a['tower:type'] = t['tower:type']
    end
end

-- ---------------------------------------------------------------------------

local get_attributes = function(object)
    local t = object.tags
    local a = {}

    local is_poi = false
    for _, k in ipairs({'amenity', 'leisure', 'tourism', 'shop', 'man_made',
                        'historic', 'emergency', 'highway', 'office'}) do
        local v = get_value[k](t[k])
        if v then
            a[k] = v
            if add_extra_attributes[k] then
                add_extra_attributes[k](a, t)
            end
            is_poi = true
        end
    end

    if not is_poi then
        return nil
    end

    a.housename = t['addr:housename']
    a.housenumber = t['addr:housenumber']

    themepark.themes.core.add_name(a, object)
    themepark:add_debug_info(a, t)

    return a
end

-- ---------------------------------------------------------------------------

themepark:add_proc('node', function(object, data)
    local a = get_attributes(object)
    if a then
        a.geom = object:as_point()
        themepark:insert('pois', a)
        data.shortbread_in_pois = true
    end
end)

themepark:add_proc('area', function(object, data)
    local a = get_attributes(object)
    if a then
        a.geom = object:as_area():centroid()
        themepark:insert('pois', a)
        data.shortbread_in_pois = true
    end
end)

-- ---------------------------------------------------------------------------
