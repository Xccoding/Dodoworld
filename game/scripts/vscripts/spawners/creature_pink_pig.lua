CREATEURE_COUNT = 1
REFRESH_TIME_MIN = 3
REFRESH_TIME_MAX = 10
SPAWN_RADIUS_MIN = 30
SPAWN_RADIUS_MAX = 300

thisEntity.CreatureGroup = {}

thisEntity:SetContextThink("creature_pink_pig", function ()
    for i = 1, CREATEURE_COUNT do
        if thisEntity.CreatureGroup[i] == nil or thisEntity.CreatureGroup[i]:IsNull() or (not thisEntity.CreatureGroup[i]:IsAlive()) then
            CreateUnitByNameAsync("creature_foreman_calgima", thisEntity:GetAbsOrigin() + RandomVector(RandomFloat(SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX)), true, nil, nil, DOTA_TEAM_NEUTRALS, function (unit)
                thisEntity.CreatureGroup[i] = unit
                unit:SetForwardVector(RandomVector(1))
                unit.spawn_entity = thisEntity
                unit.wander_type = AI_WANDER_TYPE_ACTIVE
                unit:AddNewModifier(unit, nil, "modifier_disable_autoattack_custom", {})
                unit:AddNewModifier(unit, nil, "modifier_no_combat_slow", {})
            end)
        end
    end
    return RandomFloat(REFRESH_TIME_MIN, REFRESH_TIME_MAX)
end, 1)


