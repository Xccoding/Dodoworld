
thisEntity.CreatureGroup = {}

SPAWNERKV_KEYS = {
    CreatureCount = 1,
    RefreshTimeMin = -1,
    RefreshTimeMax = -1,
    SpawnRadiusMin = 0,
    SpawnRadiusMax = 0,
    RandomFaceForward = 0,
    SpawnDelay = 1,
}

--获取字符串对应的生物
function GetSpawnerCreatureName( EntityName )
    return string.gsub(string.match(EntityName, "[A-Za-z0-9_]+_spawner"), "_spawner", "")
end

--获取Spawner的后两位，也就是序号
function GetSpawnerIndex( EntityName )
    local spawner_index_string = string.gsub(EntityName, "[A-Za-z0-9_]+_spawner_", "")
    local spawner_index = 0
    for i = 1, string.len(spawner_index_string) do
        spawner_index = spawner_index + tonumber(string.sub(spawner_index_string, - i,-i)) * math.pow(10, i - 1)
    end
    return spawner_index
end

--获取Spawner的默认配置
function GetOriginalSpawnerName(EntityName)
    local OriginalSpawnerName = string.gsub(EntityName, "_spawner_[0-9]+", "_spawner_00")
    return OriginalSpawnerName
end

thisEntity.spawn_time = GameRules:GetGameTime()
thisEntity.SpawnFunction = function () 
    if thisEntity.SpawnerKv == nil then
        thisEntity.SpawnerKv = {}
        for key, value in pairs(SPAWNERKV_KEYS) do
            if KeyValues.SpawnerKv[thisEntity:GetName()] == nil then
                if KeyValues.SpawnerKv[GetOriginalSpawnerName(thisEntity:GetName())] ~= nil then
                    thisEntity.SpawnerKv[key] = KeyValues.SpawnerKv[GetOriginalSpawnerName(thisEntity:GetName())][key] or value
                else
                    thisEntity.SpawnerKv[key] = value
                end
            else
                if KeyValues.SpawnerKv[thisEntity:GetName()][key] == nil then
                    if KeyValues.SpawnerKv[GetOriginalSpawnerName(thisEntity:GetName())] ~= nil then
                        thisEntity.SpawnerKv[key] = KeyValues.SpawnerKv[GetOriginalSpawnerName(thisEntity:GetName())][key] or value
                    else
                        thisEntity.SpawnerKv[key] = value
                    end
                else
                    thisEntity.SpawnerKv[key] = KeyValues.SpawnerKv[thisEntity:GetName()][key]
                end
            end
        end
    end
    if GameRules:GetGameTime() - thisEntity.spawn_time < thisEntity.SpawnerKv.SpawnDelay then
        return thisEntity.SpawnerKv.SpawnDelay - (GameRules:GetGameTime() - thisEntity.spawn_time)
    end
    for i = 1, thisEntity.SpawnerKv.CreatureCount do
        if thisEntity.CreatureGroup[i] == nil or thisEntity.CreatureGroup[i]:IsNull() or (not thisEntity.CreatureGroup[i]:IsAlive()) then
            CreateUnitByNameAsync(GetSpawnerCreatureName(thisEntity:GetName()), thisEntity:GetAbsOrigin() + RandomVector(RandomFloat(thisEntity.SpawnerKv.SpawnRadiusMin, thisEntity.SpawnerKv.SpawnRadiusMax)), true, nil, nil, DOTA_TEAM_NEUTRALS, function (unit)
                thisEntity.CreatureGroup[i] = unit
                unit.spawn_entity = thisEntity

                local slow_down = 0
                if unit.kv_ai_table ~= nil and type(unit.kv_ai_table) == "table" then
                    slow_down = unit.kv_ai_table.SlowNoComabt or 0
                end
                
                if thisEntity.SpawnerKv.RandomFaceForward ~= 0 then
                    unit:SetForwardVector(RandomVector(1))
                else
                    unit:SetForwardVector(thisEntity:GetForwardVector())
                end
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
    
end
thisEntity:SetContextThink(DoUniqueString("common_spawn"), thisEntity.SpawnFunction, 0.1)


