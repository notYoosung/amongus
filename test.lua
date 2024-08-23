local function capitalize(str)
    if #str <= 1 then return str:upper() end
    return str:sub(1, 1):upper() .. str:sub(2, str:len())
end
