local statsFile = Infinity.PoE2.getFileController():getStatsFile()

---@param name string
---@return number
local function getStatId(name)
    local stat = statsFile:getByKey(name)
    if stat == nil then
        print('Warning: PoE2Lib.Combat.FlaskStats - getStatId(): stat not found: ' .. name)
        return 0
    end
    return stat.Id
end

local FlaskStats = { --
    --- Local stat on the flask
    LocalChargesUsed = getStatId('local_charges_used_+%%'),
    LocalFlaskRecoveryRate = getStatId('local_flask_recovery_speed_+%%'),
    LocalFlaskAmountToRecover = getStatId('local_flask_amount_to_recover_+%%'),
    LocalFlaskAmountToRecoverLowLife = getStatId('local_flask_amount_to_recover_+%%_when_on_low_life'),
    LocalFlaskRecoversInstantly = getStatId('local_flask_recovers_instantly'),
    LocalFlaskRecoversInstantlyLowLife = getStatId('local_flask_recover_instantly_when_on_low_life'),

    --- Cleanses
    LocalImmunityBleeding = getStatId('local_flask_immune_to_bleeding_and_corrupted_blood_during_flask_effect'),
    LocalImmunityBurning = getStatId('local_flask_dispels_burning_and_ignite_immunity_during_effect'),
    LocalImmunityChill = getStatId('local_flask_immune_to_freeze_and_chill_during_flask_effect'),
    LocalImmunityPoison = getStatId('local_flask_immune_to_poison_during_flask_effect'),
    LocalImmunityShock = getStatId('local_flask_immune_to_shock_during_flask_effect'),

    LocalDispellBleeding = getStatId('local_flask_bleeding_immunity_if_bleeding_and_remove_corrupted_blood_s'),
    LocalDispellBurning = getStatId('local_flask_ignite_immunity_if_ignited_and_remove_burning_s'),
    LocalDispellChill = getStatId('local_flask_chill_or_freeze_immunity_if_chilled_or_frozen_s'),
    LocalDispellHindered = getStatId('local_flask_immune_to_hinder_for_x_seconds_if_hindered'),
    LocalDispellMaimed = getStatId('local_flask_immune_to_maim_for_x_seconds_if_maimed'),
    LocalDispellPoison = getStatId('local_flask_poison_immunity_if_poisoned_s'),
    LocalDispellShock = getStatId('local_flask_shock_immunity_if_shocked_s'),

    LocalRemoveCurses = getStatId('local_flask_remove_curses_on_use'),

    --- Global stat on the player
    FlaskChargesUsed = getStatId('flask_charges_used_+%%'),
    FlaskManaChargesUsed = getStatId('flask_mana_charges_used_+%%'),
    OnLowLife = getStatId('on_low_life'),
    TotalLifeRecoveryPerMinuteFromFlasks = getStatId('total_life_recovery_per_minute_from_flasks'),
    FlaskLifeRecovery = getStatId('flask_life_to_recover_+%%'),
    FlaskRecoveryRate = getStatId('flask_recovery_speed_+%%'),
    MasterSurgeon = getStatId('life_flask_effects_are_not_removed_at_full_life'),
    EternalYouth = getStatId('keystone_eternal_youth'),
}

return FlaskStats
