local expire = {}
for zoom=10,14 do
    expire[zoom] = osm2pgsql.define_expire_output({
        maxzoom = zoom,
        filename = "z"..zoom..".txt"
    })
end

return expire
