
thisEntity.CreatureGroup = {}

local unit_name = string.gsub(string.match(thisEntity:GetName(), "[A-Za-z0-9_]+_spawner"), "_spawner", "")
thisEntity:SetContextThink(DoUniqueString("common_spawn"), function ()
    if thisEntity.SpawnerKv == nil then
        thisEntity.SpawnerKv = {}
        thisEntity.SpawnerKv.CreatureCount = KeyValues.SpawnerKv[thisEntity:GetName()].CreatureCount
        thisEntity.SpawnerKv.RefreshTimeMin = KeyValues.SpawnerKv[thisEntity:GetName()].RefreshTimeMin
        thisEntity.SpawnerKv.RefreshTimeMax = KeyValues.SpawnerKv[thisEntity:GetName()].RefreshTimeMax
        thisEntity.SpawnerKv.SpawnRadiusMin = KeyValues.SpawnerKv[thisEntity:GetName()].SpawnRadiusMin
        thisEntity.SpawnerKv.SpawnRadiusMax = KeyValues.SpawnerKv[thisEntity:GetName()].SpawnRadiusMax
    end
    for i = 1, thisEntity.SpawnerKv.CreatureCount do
        if thisEntity.CreatureGroup[i] == nil or thisEntity.CreatureGroup[i]:IsNull() or (not thisEntity.CreatureGroup[i]:IsAlive()) then
            CreateUnitByNameAsync(unit_name, thisEntity:GetAbsOrigin() + RandomVector(RandomFloat(thisEntity.SpawnerKv.SpawnRadiusMin, thisEntity.SpawnerKv.SpawnRadiusMax)), true, nil, nil, DOTA_TEAM_NEUTRALS, function (unit)
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
    if thisEntity.SpawnerKv.RefreshTimeMin ~= -1 and thisEntity.SpawnerKv.RefreshTimeMax ~= -1 then
        return RandomFloat(thisEntity.SpawnerKv.RefreshTimeMin, thisEntity.SpawnerKv.RefreshTimeMax)
    else
        return nil
    end
    
end, 1)


