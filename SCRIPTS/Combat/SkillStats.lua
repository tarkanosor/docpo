local statsFile = Infinity.PoE2.getFileController():getStatsFile()

---@param key string
---@return number
local function getStatId(key)
    local stat = statsFile:getByKey(key)
    if stat == nil then
        print('Warning: getStatId(), stat not found: ' .. key)
        return 0
    end
    return stat.Id
end

--- Skill IDs tend to change, so we get the IDs from the file by name.
---@class PoE2Lib.Combat.SkillStats
local SkillStats = {
    AttackDuration = getStatId('attack_duration_ms'),
    CastDuration = getStatId('spell_cast_duration_ms'),

    -- Skill types
    IsPersistent = getStatId('skill_is_persistent'),
    IsBuffSkill = getStatId('skill_is_buff_skill'),
    IsCrossbowSkill = getStatId('skill_is_crossbow_skill'),
    IsCrossbowAmmoSkill = getStatId('skill_is_crossbow_ammo_skill'),
    IsInstant = getStatId('skill_is_instant'),
    IsChannelled = getStatId('skill_is_channelled'),
    IsOfferingSkill = getStatId('skill_is_offering_skill'),
    SkillCreatesMinions = getStatId('skill_creates_minions'),
    CanPerformSkillWhileMoving = getStatId('can_perform_skill_while_moving'),
    CanPerformSkillWhileMounted = getStatId('can_perform_skill_while_mounted'), -- Or skill_enabled_while_mounted?

    -- Skill stats
    NumberOfTempestBellAllowed = getStatId('number_of_tempest_bells_allowed'),
    RequiredComboStack = getStatId('virtual_skill_required_number_of_combo_stacks'),
    NumberOfSkeletalConstructsAllowed = getStatId('number_of_skeletal_constructs_allowed'),
    BaseSkillCreatesSkeletonMinions = getStatId('base_skill_creates_skeleton_minions'),
    DodgeRollTravelDistance = getStatId('dodge_roll_travel_distance'),
    BlinkTravelDistance = getStatId('blink_travel_distance'),
    NumberOfRemoteSpearMinesAllowed = getStatId('number_of_remote_spear_mines_allowed'),
    NumberOfOverchargedSpearsAllowed = getStatId('number_of_overcharged_spears_allowed'),
    RepeatLastStepOfComboAttack = getStatId('repeat_last_step_of_combo_attack'),
    TotemRange = getStatId('totem_range'),

    -- Perfect Strike
    PerfectStrikeTimingWindowMS = getStatId('virtual_perfect_strike_timing_window_ms'),
    ChannelEndDurationAsPercOfAttackTime = getStatId('channel_end_duration_as_%%_of_attack_time'),
    SkillAnimationDurationMultiplierOverride = getStatId('skill_animation_duration_multiplier_override'),
    ChannelStartLockCancellingOfAttackTime = getStatId('channel_start_lock_cancelling_of_attack_time_%%'),
    ChannelSkillEndAnimationDurationMultiplierPermyriad = getStatId('channel_skill_end_animation_duration_multiplier_permyriad'),

    -- PoE1
    LifeCost = getStatId('life_cost'),
    ManaCost = getStatId('mana_cost'),
    ESCost = getStatId('es_cost'),
    RageCost = getStatId('rage_cost'),
    ManaReservation = getStatId('mana_reservation'),
    ManaReservationPermyriad = getStatId('mana_reservation_permyriad'),
    LifeReservation = getStatId('life_reservation'),
    LifeReservationPermyriad = getStatId('life_reservation_permyriad'),
    SpiritReservation = getStatId('spirit_reservation'),
    UsableWithoutManaCostWhileSurrounded = getStatId('skills_are_usable_without_mana_cost_while_surrounded'),

    IsCastingSkill = getStatId('casting_spell'),
    IsAttackSkill = getStatId('skill_is_attack'),
    IsBowSkill = getStatId('skill_is_bow_skill'),
    IsTravelSkill = getStatId('skill_is_travel_skill'),
    IsAuraSkill = getStatId('skill_is_aura_skill'),
    IsHeraldSkill = getStatId('skill_is_herald_skill'),
    IsBlessingSkill = getStatId('skill_is_blessing_skill'),
    IsTotemSkill = getStatId('is_totem'),
    IsTrapSkill = getStatId('is_trap'),
    IsMineSkill = getStatId('skill_is_mined'),
    IsLinkSkill = getStatId('display_link_stuff'),

    CurseApplyAsAura = getStatId('curse_apply_as_aura'), -- Blasphemy support

    IsTriggered = getStatId('skill_is_triggered'),

    DealNoDamage = getStatId('deal_no_damage'),
    HundredCastsPerSecond = getStatId('hundred_times_casts_per_second'),
    HundredAttacksPerSecond = getStatId('hundred_times_attacks_per_second'),

    BuffEffectDuration = getStatId('buff_effect_duration'),
    CooldownDoesNotTick = getStatId('skill_cooldown_does_not_tick'),
    VirtualCooldownSpeedPerc = getStatId('virtual_cooldown_speed_+%%'),
    VirtualTrapThrowingSpeed = getStatId('virtual_trap_throwing_speed_+%%'),
    VirtualMineThrowingSpeed = getStatId('virtual_mine_throwing_speed_+%%'),
    SummonTotemCastSpeed = getStatId('summon_totem_cast_speed_+%%'),
    UnleashSealInterval = getStatId('virtual_support_anticipation_charge_gain_interval_ms'),
    SpellRepeatCount = getStatId('spell_repeat_count'),
    ActiveSkillAoERadius = getStatId('active_skill_area_of_effect_radius'),
    ActiveSkillSecondaryAoERadius = getStatId('active_skill_secondary_area_of_effect_radius'),
    ExertsCount = getStatId('skill_empowers_next_x_melee_attacks'),
    VirtualExertsCount = getStatId('virtual_skill_empowers_next_x_melee_attacks'),

    MaxTotems = getStatId('skill_display_number_of_totems_allowed'),
    TotemsPerSummon = getStatId('number_of_totems_to_summon'),
    MaxGolems = getStatId('number_of_golems_allowed'),
    MaxSkeletons = getStatId('number_of_skeletons_allowed'),
    MaxZombies = getStatId('number_of_zombies_allowed'),
    MaxSpectres = getStatId('number_of_spectres_allowed'),
    MaxRelics = getStatId('number_of_relics_allowed'),
    MaxRagingSpirits = getStatId('number_of_raging_spirits_allowed'),
    MaxSpinningBlades = getStatId('maximum_number_of_spinning_blades'),
    MaxUnleashSeals = getStatId('skill_max_unleash_seals'),

    -- Player stat, not a skill stat
    EldritchBattery = getStatId('virtual_spend_energy_shield_for_costs_before_mana'),
    LinkSkillsCanTargetMinions = getStatId('link_skills_can_target_minions'),
    ActorIsPlayerMinion = getStatId('is_player_minion'),
    --MovementSpeed = getStatId('movement_velocity_+%%'),
    MaximumFanaticismCharges = getStatId('maximum_fanaticism_charges'),
    IsDodgeRolling = getStatId('is_dodge_rolling'),
    IsMounted = getStatId('is_mounted'),
    IsSurrounded = getStatId('virtual_is_surrounded'),
    EnforcedWalkingSpeed = getStatId('enforced_walking_movement_speed_+permyriad_override'),
    IsInTown = getStatId('is_in_town'),
}

return SkillStats
