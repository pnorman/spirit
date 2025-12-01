local function contains(list, x)
    for i = 1, #list do
        if list[i] == x then return true end
    end
    return false
end

-- @param t1 {}
-- @param t2 {}
local function mergeList(t1,t2)
    local tOut = {}

    for i = 1, #t1 do
        tOut[i] = t1[i]
    end

    for i = 1, #t2 do
        tOut[i + #t1] = t2[i]
    end

    return tOut
end


--- Normalizes layer tags to integers
-- @param v The layer tag value
-- @return The input value if it is an integer between -100 and 100, or nil otherwise
local function layer (v)
    if v and string.find(v, "^-?%d+$") and tonumber(v) < 100 and tonumber(v) > -100 then -- check if value exists, is numeric, and is in range
        return v
    end
    return nil
end

return { contains=contains, layer=layer, mergeList=mergeList }
