local CombatAddons = {}

--- This is an alphabetically ordered list of combat addons. Unlike the
--- SkillHandlerList, it is not logically ordered, because there is no hierarchy
--- to impose onto the list.
CombatAddons.AddonNames = {}

do
    ---@type PoE2Lib.Combat.CombatAddon[]
    CombatAddons.List = {}

    --- A map of table<name, handler> that we can use to deserialize configs and
    --- lookup handlers classes by their full names.
    --- @type table<string, PoE2Lib.Combat.CombatAddon>
    CombatAddons.NameMap = {}

    ---@type table<PoE2Lib.Combat.CombatAddon, string>
    CombatAddons.NamesByAddons = {}

    CombatAddons.ListLabels = {}

    for _, addonName in ipairs(CombatAddons.AddonNames) do
        local addon = require("PoE2Lib.Combat.CombatAddons." .. addonName)
        table.insert(CombatAddons.List, addon)
        CombatAddons.NameMap[addon] = addonName
        CombatAddons.NamesByAddons[addonName] = addon
        table.insert(CombatAddons.ListLabels, addon.shortName)
    end
end

---@param name string
---@return PoE2Lib.Combat.CombatAddon?
function CombatAddons.ByName(name)
    return CombatAddons.NameMap[name]
end

---@param addonClass PoE2Lib.Combat.CombatAddon
---@return string?
function CombatAddons.NameOf(addonClass)
    return CombatAddons.NameMap[addonClass]
end

return CombatAddons
