CREATEURE_COUNT = 1
REFRESH_TIME_MIN = 3
REFRESH_TIME_MAX = 10
SPAWN_RADIUS_MIN = 30
SPAWN_RADIUS_MAX = 300

thisEntity.CreatureGroup = {}
local unit_name = string.gsub(string.match(thisEntity:GetName(), "[A-Za-z0-9_]+_spawner"), "_spawner", "")
thisEntity:SetContextThink("creature_pink_pig", function ()
    for i = 1, CREATEURE_COUNT do
        if thisEntity.CreatureGroup[i] == nil or thisEntity.CreatureGroup[i]:IsNull() or (not thisEntity.CreatureGroup[i]:IsAlive()) then
            CreateUnitByNameAsync("creature_watcher_adolph", thisEntity:GetAbsOrigin() + RandomVector(RandomFloat(SPAWN_RADIUS_MIN, SPAWN_RADIUS_MAX)), true, nil, nil, DOTA_TEAM_NEUTRALS, function (unit)
                thisEntity.CreatureGroup[i] = unit
                unit.spawn_entity = thisEntity

                local slow_down = 0
                if unit.kv_ai_table ~= nil and type(unit.kv_ai_table) == "table" then
                    slow_down = unit.kv_ai_table.SlowNoComabt or 0
                end
                unit:SetForwardVector(RandomVector(1))
                unit:AddNewModifier(unit, nil, "modifier_disable_autoattack_custom", {})
                unit:AddNewModifier(unit, nil, "modifier_no_combat_slow", {slow_down = slow_down})
            end)
        end
    end
    return RandomFloat(REFRESH_TIME_MIN, REFRESH_TIME_MAX)
end, 1)


