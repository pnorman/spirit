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

local access_mapping = {
    yes = 'yes',
    designated = 'yes',
    permissive = 'yes',
    customers = 'limited',
    destination = 'limited',
    agricultural = 'limited',
    forestry = 'limited',
    delivery = 'limited',
    discouraged = 'limited',
    permit = 'limited',
    dismount = 'no',
    military = 'no',
    private = 'no',
    no = 'no'
}

local function access (tags)
    local a = {
        motorcar = access_mapping[tags.motorcar] or access_mapping[tags.motor_vehicle]
            or access_mapping[tags.vehicle] or access_mapping[tags.access] or nil,
        bicycle = access_mapping[tags.bicycle] or access_mapping[tags.vehicle] or access_mapping[tags.access] or nil,
        foot = access_mapping[tags.foot] or access_mapping[tags.access] or nil,
        horse = access_mapping[tags.horse] or access_mapping[tags.access] or nil
    }

    if next(a) == nil then
        return nil
    else
        return a
    end
end


return { contains=contains, layer=layer, mergeList=mergeList, access=access}
