local Atlas = {}

function Atlas.GetAtlasPanel()
    return Infinity.PoE2.getGameStateController():getInGameState():getInGameUI():getAtlasPanel()
end

function Atlas.IsAtlasPanelVisible()
    local atlasPanel = Atlas.GetAtlasPanel()
    -- We check atlasPanel and each parent if they are visible
    if not atlasPanel or not atlasPanel:isVisible() then
        return false
    end

    local root = atlasPanel:getRoot()
    local parent = atlasPanel:getParent()
    while parent and parent.address ~= root.address do
        if not parent:isVisible() then
            return false
        end

        parent = parent:getParent()
    end

    return true
end

---@return table<integer, IGUIAtlasNode>
function Atlas.GetTowers()
    local atlasPanel = Atlas.GetAtlasPanel()
    if not atlasPanel then
        return {}
    end

    local towers = {}
    local nodes = atlasPanel:getAtlasNodes()
    for _, node in pairs(nodes) do
        if node:isTower() then
            table.insert(towers, node)
        end
    end

    return towers
end

---@return table<integer, IGUIAtlasNode>
function Atlas.GetActivatedTowers()
    local towers = Atlas.GetTowers()
    local activatedTowers = {}
    for _, tower in pairs(towers) do
        if tower:isCompleted() and tower:isActivatedTower() then
            table.insert(activatedTowers, tower)
        end
    end

    return activatedTowers
end

---@return table<integer, IGUIAtlasNode>
function Atlas.GetUnactivatedTowers()
    local towers = Atlas.GetTowers()
    local unactivatedTowers = {}
    for _, tower in pairs(towers) do
        if tower:isCompleted() and not tower:isActivatedTower() then
            table.insert(unactivatedTowers, tower)
        end
    end

    return unactivatedTowers
end

return Atlas
