local expire = {}

local function shortbread(minzoom, maxzoom, layer, mode)
    -- osm2pgsql requies a minzoom of at least 1
    if minzoom == 0 then
        minzoom = 1
    end
    expire[layer] = {}
    for zoom=minzoom, maxzoom do
        table.insert(expire[layer],
            {
                output=osm2pgsql.define_expire_output({
                    maxzoom = zoom,
                    filename = "z"..zoom.."-"..layer..".txt"
                }),
                mode = mode
            })
    end
    return expire[layer]
end

return {shortbread = shortbread}
