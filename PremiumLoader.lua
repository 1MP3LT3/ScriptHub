-- // <Keys>

local Keys = {}

-- // <Loader>

local PremiumLoader = function(Key)
    local KeyName = "ForestFire/PremiumKey.txt"
    
    if Key then
        writefile(KeyName, Key)
    end

    if not isfile(KeyName) then
        return
    end

    local Key = readfile(KeyName)
    
    if table.find(Keys, Key) then
        return true
    else
        return false
    end
end

return PremiumLoader
