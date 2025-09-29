---@type { ByName: table<string, Mod[]>, SortedNames: string[] }
local WaystoneModTypes = { ByName = {}, SortedNames = {} }
do
    for _, mod in pairs(Infinity.PoE2.getFileController():getModsFile():getAll()) do
        local genType = mod:getGenerationType()
        if mod:getDomain() == 6 and (genType == EModGenerationType_Prefix or genType == EModGenerationType_Suffix) then
            local modType = mod:getModType()
            local typeName = modType:getName()
            if WaystoneModTypes.ByName[typeName] == nil then
                WaystoneModTypes.ByName[typeName] = {}
                table.insert(WaystoneModTypes.SortedNames, typeName)
            end
            table.insert(WaystoneModTypes.ByName[typeName], mod)
        end
    end
    table.sort(WaystoneModTypes.SortedNames)
end

return WaystoneModTypes
