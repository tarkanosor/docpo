local Items = {}

local metaPathToItemsMap = {}

function Items.GetItemName(itemMetaPath)
    if metaPathToItemsMap[itemMetaPath] == nil then
        local baseItemTypesFile = Infinity.PoE2.getFileController():getBaseItemTypesFile()
        local baseItemTypes = baseItemTypesFile:getByMetaPath(itemMetaPath)
        metaPathToItemsMap[itemMetaPath] = baseItemTypes and baseItemTypes:getName() or "UNKNOWN"
    end

    return metaPathToItemsMap[itemMetaPath]
end

return Items
