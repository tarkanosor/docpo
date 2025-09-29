local CustomPatterns = require("PoE2Lib.Combat.Evade.CustomPatterns")
local PolygonsXY = require("CoreLib.PolygonsXY")

---@type PoE2Lib.Combat.Evade.CustomPatterns
local CustomPatterns_Bosses = CustomPatterns()

---@param original string
---@param copy string
local function duplicate(original, copy)
    CustomPatterns_Bosses:add(copy, CustomPatterns_Bosses.aoMapping[original])
end

--------------------------------------------------------------------------------
-- Bloated Miller (Act 1)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/SwollenMiller/SwollenMiller.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "slam_01" then
        if animation.position >= 1.500 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
                20,
                12
            ))
        end
    end

    if animation.name == "charge_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getDestination(),
            20,
            12
        ))
    end
end)

--------------------------------------------------------------------------------
-- The Rust King (Act 1)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Effects/Spells/monsters_effects/Act1_FOUR/RustKing/spike_proj.ao", function(spike, addPolygon)
    addPolygon(true, spike:getActorId(), 300, PolygonsXY.Rectangle(
        spike:getLocation(),
        spike:getLocation() + Vector3(0, -200, 0):getRotatedZ(spike:getRotation()),
        15
    ))
end)

--------------------------------------------------------------------------------
-- Rathbreaker (Act 2)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/HyenaMonster/Rathbreaker.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "axe_slam_01" then
        if animation.position >= 2.488 and animation.position <= 2.617
        or animation.position >= 3.195 and animation.position <= 3.503
        or animation.position >= 5.360
        then
            addPolygon(true, boss:getActorId(), 300, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
                20
            ))
        else
            addPolygon(false, boss:getActorId(), 300, PolygonsXY.Cone(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
                120,
                20
            ))
        end
    end

    if animation.name == "enraged_overhead_chop_01" then
        if animation.position >= 1.025 then
            addPolygon(true, boss:getActorId(), 300, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
                30
            ))
        end
    end
end)

--------------------------------------------------------------------------------
-- Mighty Silverfist (Act 2)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/Quadrilla/QuadrillaW.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "sweep_slam_pillar_left_01" then
        if animation.position >= 2.1656689643859865 - 0.100 then
            local direction = Vector3(293.4079895019531, -374.4309997558594, 0):getRotatedZ(boss:getRotation())
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + direction * 100,
                25
            ))
        end
    end
    if animation.name == "sweep_slam_pillar_right_01" then
        if animation.position >= 1.941101312637329 - 0.100 then
            local direction = Vector3(-391.1650085449219, -305.31298828125, 0):getRotatedZ(boss:getRotation())
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + direction * 100,
                25
            ))
        end
    end
    if animation.name == "heavy_slam_pillar_01" then
        if animation.position >= 0.9426788091659546 - 0.100 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
                25
            ))
        end
    end
    if animation.name == "spin_slam_pillar_01" then
        if animation.position >= 3.621109962463379 - 0.100 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
                25
            ))
        end
    end
end)

--------------------------------------------------------------------------------
-- Azarian (Act 2)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/ForsakenSon/ForsakenSon.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "groundslam_01" then
        addPolygon((animation.position >= 1.362), boss:getActorId(), 300, PolygonsXY.ConeMinWidth(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -70, 0):getRotatedZ(boss:getRotation()),
            45,
            10,
            12
        ))
    end

    if animation.name == "cyclone_01" then
        addPolygon(true, boss:getActorId(), 300, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getDestination(),
            30,
            12
        ))
    end

    if animation.name == "throw_quad_01" then
        addPolygon((animation.position >= 1.200), boss:getActorId(), 300, PolygonsXY.Rectangle(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
            40
        ))
    end
end)

--------------------------------------------------------------------------------
-- Blackjaw (Act 3)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/BlackJawSuperunique/BlackJawSuperunique.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "emerge_statue_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Cone(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -80, 0):getRotatedZ(boss:getRotation()),
            180,
            20
        ))
    end

    if animation.name == "slam_phase01_01" then
        if animation.position >= 0.700 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -40, 0):getRotatedZ(boss:getRotation()),
                20,
                15
            ))
        end
    end

    if animation.name == "fire_breath_left_01" or animation.name == "fire_breath_right_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Cone(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -80, 0):getRotatedZ(boss:getRotation()),
            120,
            15
        ))
    end

    if animation.name == "slam_triple_phase01_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Cone(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -200, 0):getRotatedZ(boss:getRotation()),
            180,
            10
        ))
    end

    if animation.name == "leap_slam_phase02_01" then
        if animation.position >= 0.860 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
                boss:getDestination(),
                50,
                360 / 20
            ))
        end
    end

    if animation.name == "fire_breath_spin_cleave_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
            boss:getLocation(),
            40,
            360 / 20
        ))
    end

    if animation.name == "fire_breath_lacerate_01" then
        if animation.position >= 5.643 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -30, 0):getRotatedZ(boss:getRotation()),
                30,
                10
            ))
        elseif animation.position >= 2.332 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -200, 0):getRotatedZ(boss:getRotation()),
                30
            ))
        end
    end
end)

--------------------------------------------------------------------------------
-- Mektul (Act 3)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/VaalForgeMaster/VaalForgeMaster.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "underarm_waves_01" then
        if animation.position >= 2.200 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -200, 0):getRotatedZ(boss:getRotation()),
                40
            ))
        end
    end

    if animation.name == "leap_slam_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -30, 0):getRotatedZ(boss:getRotation()),
            20,
            10
        ))
    end

    if animation.name == "volcanic_fissure_01" then
        local location = boss:getLocation()
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
            location,
            location + location:getDirectionVector(boss:getCurrentAction():getDestinationLocation()) * 200,
            30
        ))
    end

    if animation.name == "hammer_attack_01" then
        if animation.position >= 1.000 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
                boss:getCurrentAction():getDestinationLocation(),
                20,
                10
            ))
        end
    end
end)

CustomPatterns_Bosses:add("Metadata/Monsters/VaalForgeMaster/Lava/lava_edge.ao", function(lava, addPolygon)
    local location = lava:getLocation()
    local rotation = lava:getRotation()
    addPolygon(true, lava:getActorId(), 100, PolygonsXY.Rectangle(
        location - Vector3(0, -200, 0):getRotatedZ(rotation),
        location + Vector3(0, -20, 0):getRotatedZ(rotation),
        80
    ))
    addPolygon(false, lava:getActorId() + 1e6, 100, PolygonsXY.Rectangle(
        location - Vector3(0, -210, 0):getRotatedZ(rotation),
        location + Vector3(0, -30, 0):getRotatedZ(rotation),
        80
    ))
end)

--------------------------------------------------------------------------------
-- Queen of Filth (Act 3)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/QueenOfFilth/QueenOfFilth.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "emerge_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
            25,
            12
        ))
    end

    if animation.name == "overhead_slam_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -30, 0):getRotatedZ(boss:getRotation()),
            25,
            12
        ))
    end

    if animation.name == "roll_slam_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -100, 0):getRotatedZ(boss:getRotation()),
            25,
            12
        ))
    end

    if animation.name == "slap_slam_01" then
        if animation.position >= 1.000 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -30, 0):getRotatedZ(boss:getRotation()),
                25,
                12
            ))
        end
    end

    if animation.name == "double_slam_01" then
        if animation.position >= 0.600 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -50, 0):getRotatedZ(boss:getRotation()),
                25,
                12
            ))
        end
    end
end)

--------------------------------------------------------------------------------
-- Viper Napuatzi (Act 3)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/VaalMonsters/ViperNapuatzi/ViperNapuatzi.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "spear_cyclone_start_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
            boss:getLocation(),
            30,
            12
        ))
    end
    if animation.name == "spear_serpent_strike_01" then
        if animation.position >= 2.100 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -200, 0):getRotatedZ(boss:getRotation()),
                30
            ))
        end
    end
    if animation.name == "spear_combo_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -20, 0):getRotatedZ(boss:getRotation()),
            15,
            12
        ))
    end
    if animation.name == "spear_throw_01" then
        if animation.position >= 1.100 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
                boss:getLocation(),
                boss:getLocation() + Vector3(0, -200, 0):getRotatedZ(boss:getRotation()),
                10
            ))
        end
    end
    if animation.name == "spear_attack_jump_move_01" then
        if boss:getCurrentDamagePattern() ~= nil then
            local location = boss:getLocation()
            local destination = boss:getDestination()
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                location,
                destination + location:getDirectionVector(destination) * 20,
                15,
                12
            ))

            -- addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
            --     location,
            --     location + Vector3(0, -100, 0):getRotatedZ(rotation),
            --     20
            -- ))
        end
    end
    if animation.name == "spear_dash_fwd_02" then
        if boss:getCurrentDamagePattern() ~= nil then
            local location = boss:getLocation()
            local destination = boss:getDestination()
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Pill(
                location,
                destination + location:getDirectionVector(destination) * 20,
                15,
                12
            ))
            -- addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
            --     location,
            --     location + Vector3(0, -100, 0):getRotatedZ(rotation),
            --     20
            -- ))
        end
    end
    if animation.name == "caster_spinning_slam_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
            boss:getLocation(),
            40,
            12
        ))
    end

    -- if animation.name == "caster_snake_barrage_01" then
    --     addPolygon(true, boss:getActorId(), 100, PolygonsXY.Rectangle(
    --         location,
    --         location + Vector3(0, -200, 0):getRotatedZ(rotation),
    --         40
    --     ))
    -- end
end)

--------------------------------------------------------------------------------
-- Yama the White (Act 4)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/FallenYamaTheWhite/FallenYamaTheWhite.ao", function(boss, addPolygon)
    local animation = boss:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "staff_swipe_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Cone(
            boss:getLocation(),
            boss:getLocation() + Vector3(0, -70, 0):getRotatedZ(boss:getRotation()),
            180,
            20
        ))
    end

    if animation.name == "totems_end_01" then
        addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
            boss:getLocation(),
            30,
            20
        ))
    end

    if animation.name == "totems_end_ground_01" or animation.name == "totems_end_ground_02" then
        if animation.position >= 1.450 then
            addPolygon(true, boss:getActorId(), 100, PolygonsXY.Circle(
                boss:getCurrentAction():getDestinationLocation(),
                30,
                20
            ))
        end
    end
end)

--------------------------------------------------------------------------------
-- Azmazi, the Faridun Prince (Interlude 2)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/FaridunOlroth/FaridunBlackPrince.ao", function(actor, addPolygon)
    local animation = actor:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "dash_01" then
        if animation.position >= 0.798 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Pill(
                actor:getLocation(),
                actor:getCurrentAction():getDestinationLocation(),
                20,
                20
            ))
        end
    end

    if animation.name == "dash_02" then
        if animation.position >= 0.783 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Pill(
                actor:getLocation(),
                actor:getCurrentAction():getDestinationLocation(),
                20,
                20
            ))
        end
    elseif animation.name == "chrono_dash_01" then
        if animation.position >= 0.812 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Pill(
                actor:getLocation(),
                actor:getCurrentAction():getDestinationLocation(),
                20,
                20
            ))
        end
    elseif animation.name == "chrono_dash_02" then
        if animation.position >= 0.826 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Pill(
                actor:getLocation(),
                actor:getCurrentAction():getDestinationLocation(),
                20,
                20
            ))
        end
    end

    if animation.name == "slam_rupture_01" then
        if animation.position >= 1.059 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Rectangle(
                actor:getLocation(),
                actor:getLocation() + Vector3(0, -150, 0):getRotatedZ(actor:getRotation()),
                20
            ))
        end
    end

    if animation.name == "slam_rupture_03" then
        if animation.position >= 3.650 - 0.200 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Rectangle(
                actor:getLocation(),
                actor:getLocation() + Vector3(0, -150, 0):getRotatedZ(actor:getRotation()),
                20
            ))
        end
    end

    if animation.name == "clone_strike_ultimate_01" then
        if animation.position >= 7.200 then
            -- Nothing
        elseif animation.position >= 5.688 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Rectangle(
                actor:getLocation(),
                actor:getLocation() + Vector3(0, -150, 0):getRotatedZ(actor:getRotation()),
                30
            ))
        elseif animation.position >= 4.527 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Pill(
                actor:getLocation(),
                actor:getLocation() + Vector3(0, -20, 0):getRotatedZ(actor:getRotation()),
                20,
                20
            ))
        else
            addPolygon(false, actor:getActorId(), 100, PolygonsXY.Circle(
                actor:getLocation(),
                60,
                20
            ))
        end
        -- elseif animation.position >= 4.966 then
        --     addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(
        --         actor:getLocation(),
        --         150,
        --         20
        --     ))
        -- else
        --     addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(
        --         actor:getLocation(),
        --         200,
        --         20
        --     ))
        -- end
    end

    if animation.name == "triple_lacerate_01" or animation.name == "empowered_triple_lacerate_01" then
        if animation.position >= 0.912 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Rectangle(
                actor:getLocation(),
                actor:getLocation() + Vector3(0, -150, 0):getRotatedZ(actor:getRotation()),
                20
            ))
        end
    end

    if animation.name == "chrono_leap_slam_end_01" or animation.name == "chrono_leap_slam_loop_01" then
        addPolygon((animation.name == "chrono_leap_slam_end_01"), actor:getActorId(), 100, PolygonsXY.Rectangle(
            actor:getLocation(),
            actor:getLocation() + Vector3(0, -200, 0):getRotatedZ(actor:getRotation()),
            25
        ))
    end
end)

CustomPatterns_Bosses:add("Metadata/Effects/Spells/monsters_effects/Act_Interlude/FaridunOlroth/domain_expansion.ao", function(actor, addPolygon)
    addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(
        actor:getLocation(),
        60,
        20
    ))
end)

CustomPatterns_Bosses:add("Metadata/Effects/Spells/monsters_effects/Act_Interlude/FaridunOlroth/sword_spin.ao", function(actor, addPolygon)
    addPolygon(true, actor:getActorId(), 100, PolygonsXY.Rectangle(
        actor:getLocation(),
        actor:getDestination(),
        20
    ))
end)

--------------------------------------------------------------------------------
-- Lythara, the Wayward Spear (Interlude 3)
--------------------------------------------------------------------------------

duplicate("Metadata/Monsters/VaalMonsters/ViperNapuatzi/ViperNapuatzi.ao", "Metadata/Monsters/VaalMonsters/ViperNapuatzi/ViperNapuatziAzmeri.ao")

CustomPatterns_Bosses:add("Metadata/Effects/Spells/monsters_effects/Act_Interlude/AzmerianViper/mini_tornado.ao", function(actor, addPolygon)
    addPolygon(false, actor:getActorId(), 100, PolygonsXY.Pill(actor:getLocation(), actor:getLocation() + Vector3(0, -30, 0):getRotatedZ(actor:getRotation()), 15, 10))
end)

--------------------------------------------------------------------------------
-- Rakkar, the Frozen Talon (Interlude 3)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/ChaosGodOwlBoss/IceOwl/IceOwlBoss.ao", function(actor, addPolygon)
    local animation = actor:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "dash_up_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getCurrentAction():getDestinationLocation(), 30, 20))
    end
    if animation.name == "dash_kick_combo_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Rectangle(
            actor:getLocation(),
            actor:getLocation() + Vector3(0, -150, 0):getRotatedZ(actor:getRotation()),
            20
        ))
    end
end)

CustomPatterns_Bosses:add("Metadata/Monsters/ChaosGodOwlBoss/IceOwl/objects/SnowballBase.ao", function(actor, addPolygon)
    addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 15, 20))
end)

--------------------------------------------------------------------------------
-- The Abominable Yeti (Interlude 3)
--------------------------------------------------------------------------------

duplicate("Metadata/Monsters/Quadrilla/QuadrillaW.ao", "Metadata/Monsters/Quadrilla/IcyQuadrilla/IcyQuadrillaBoss.ao")

--------------------------------------------------------------------------------
-- Stormgore (Interlude 3)
--------------------------------------------------------------------------------

duplicate("Metadata/Monsters/BlackJawSuperunique/BlackJawSuperunique.ao", "Metadata/Monsters/BlackJawSuperunique/BlackjawLightning/BlackJawLightningSuperunique.ao")

--------------------------------------------------------------------------------
-- Zolin and Zelina (Interlude 3)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/VaalMonsters/Living/BloodPriests/BloodPriestFemale.ao", function(actor, addPolygon)
    local animation = actor:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "claw_whirling_blades_01" then
        if animation.position >= 0.300 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Pill(actor:getLocation(), actor:getCurrentAction():getDestinationLocation(), 20, 20))
        end
    end

    if animation.name == "claw_flurry_move_02" then
        if animation.position >= 5.000 then
            addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation() + Vector3(0, -158 / (250 / 23), 0):getRotatedZ(actor:getRotation()), 40, 20))
        end
    end

    if animation.name == "claw_combo_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Cone(actor:getLocation(), actor:getLocation() + Vector3(0, -80, 0):getRotatedZ(actor:getRotation()), 90, 20))
    end
end)

CustomPatterns_Bosses:add("Metadata/Monsters/VaalMonsters/Living/BloodPriests/BloodPriestMale.ao", function(actor, addPolygon)
end)

--------------------------------------------------------------------------------
-- Volkar (Maps, Crimson Shore)
--------------------------------------------------------------------------------

CustomPatterns_Bosses:add("Metadata/Monsters/SaltGolem/SaltGolemRattlecage.ao", function(actor, addPolygon)
    if actor:getParent() ~= nil then
        return
    end

    local animation = actor:getCurrentAnimation()
    if animation == nil then
        return
    end

    if animation.name == "boss_inert_activate_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 60, 20))
    end

    if animation.name == "barrage_01" then
        addPolygon(true, actor:getActorId(), 100, PolygonsXY.Circle(actor:getLocation(), 30, 20))
    end
end)

--------------------------------------------------------------------------------
-- Tierney, the Hateful (Maps, Creek)
--------------------------------------------------------------------------------

duplicate("Metadata/Monsters/SwollenMiller/SwollenMiller.ao", "Metadata/Monsters/SwollenMiller/SwollenMillerMAP.ao")

--------------------------------------------------------------------------------
-- Zahmir, the Blade Sovereign (Maps, Sacred Reservoir)
--------------------------------------------------------------------------------

duplicate("Metadata/Monsters/FaridunOlroth/FaridunBlackPrince.ao", "Metadata/Monsters/FaridunOlroth/FaridunOlrothMAP.ao")

return CustomPatterns_Bosses
