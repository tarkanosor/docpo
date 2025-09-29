local CustomPatterns = require("PoE2Lib.Combat.Evade.CustomPatterns")
local PolygonsXY = require("CoreLib.PolygonsXY")

---@type PoE2Lib.Combat.Evade.CustomPatterns
local CustomPatterns_Effects = CustomPatterns()

--------------------------------------------------------------------------------
-- Definitions
--------------------------------------------------------------------------------

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/monster_mods/exploding_orbs/exploding_orb.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "charge" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 20, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/general_effects/exploding_orb/abyssal_orb.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "charge" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 20, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Monsters/MonsterMods/VolatilePlants/volatile.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "spellcast_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 20, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Monsters/LeagueRitual/Daemons/volatile.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "spellcast_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 20, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Ritual/chaos_ritual/bloom_pod_large.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "ramping_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Monsters/Cenobite/CenobiteBloater/Bloater_01.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "death_blast_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 25, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Monsters/Cenobite/CenobiteBloater/Bloater_02.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "death_blast_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 25, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_01.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_02.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_03.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_04.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_05.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_06.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_07.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

CustomPatterns_Effects:add("Metadata/Effects/Spells/monsters_effects/League_Abyss/PaleWalker/mine_08.ao", function(actor, addPolygon)
    if actor:getCurrentAnimationName() == "explode" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
    end
end)

return CustomPatterns_Effects
