if Abilities_manager == nil then
    Abilities_manager = {}
end

function Abilities_manager:InitSchools()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        CustomNetTables:SetTableValue("hero_schools", tostring(playerID), { schools_index = 0 })
    end
end

function Abilities_manager:OnChangeRoleMastery(params)
    if params == nil then
        return
    end
    local unit = EntIndexToHScript(params.entindex)
    Abilities_manager:RefreshAbilitiesToRole(params)
    Abilities_manager:AutoUpgradeAbilities(unit)
end

function Abilities_manager:RefreshAbilitiesToRole(params)
    if params == nil then
        return
    end
    local unit = EntIndexToHScript(params.entindex)
    local new_schools = params.new_schools or 0

    for i = MIN_ABILITY_SLOT, MAX_ABILITY_SLOT do
        if unit:GetAbilityByIndex(i) ~= nil then
            local ability_to_remove = unit:GetAbilityByIndex(i)
            local buffs = unit:FindAllModifiers()
            for _, buff in pairs(buffs) do
                if buff:GetAbility() ~= nil and buff:GetAbility() == ability_to_remove then
                    buff:Destroy()
                end
            end
            unit:RemoveAbilityByHandle(ability_to_remove)
        end
    end

    for j = 1, 6 do
        unit:AddAbility("common_Ability6slot"):SetLevel(1)
    end
    unit:AddAbility("common_interactive"):SetLevel(1)

    local schoolData = nil

    if KeyValues.SchoolsKv[unit:GetUnitLabel()] ~= nil then
        schoolData = KeyValues.SchoolsKv[unit:GetUnitLabel()][tostring(new_schools)]
    end

    if schoolData ~= nil then
        for i = 1, 24 do
            if schoolData["Ability" .. i] ~= nil then
                unit:AddAbility(schoolData["Ability" .. tostring(i)])
            end
        end

        --更新网表
        CustomNetTables:SetTableValue("hero_schools", tostring(unit:GetPlayerOwnerID()), { schools_index = new_schools })
        -- for i = MIN_ABILITY_SLOT, MAX_ABILITY_SLOT do
        --     if unit:GetAbilityByIndex(i) ~= nil then
        --         print(unit:GetAbilityByIndex(i):GetAbilityName())
        --     end
        -- end
    end

end

function Abilities_manager:AutoUpgradeAbilities(hero)
    if hero == nil then
        return
    end
    for i = MIN_ABILITY_SLOT, MAX_ABILITY_SLOT do

        local hAbility = hero:GetAbilityByIndex(i)

        if hAbility ~= nil then
            local abilty_levels = vlua.split(KeyValues.AbilityKv[hAbility:GetAbilityName()].CustomRequiredLevel, " ") or KeyValues.AbilityKv[hAbility:GetAbilityName()].CustomRequiredLevel
            if abilty_levels ~= nil then
                if type(abilty_levels) == "table" then
                    for index = #abilty_levels, 1, -1 do
                        if hero:GetLevel() >= tonumber(abilty_levels[index]) then
                            hAbility:SetLevel(index)
                            break
                        end
                    end
                elseif type(abilty_levels) == "number" then
                    if hero:GetLevel() >= abilty_levels then
                        hAbility:SetLevel(1)
                    end
                end
                
            end
        end
    end
end

function Abilities_manager:GetCurrentSchools(unit)
    if unit == nil then
        return 0
    else
        local info = CustomNetTables:GetTableValue("hero_schools", tostring(unit:GetPlayerOwnerID()))
        if info ~= nil then
            return info.schools_index
        else
            return 0
        end
    end
end

function Abilities_manager:OnCustomCastAbility(event)
    local ability = EntIndexToHScript(event.ability)
    if ability == nil then
        return
    end
    local hCaster = ability:GetCaster()
    local hTarget
    local vPos = Vector(event.cursor_pos.x, event.cursor_pos.y, event.cursor_pos.z)
    local player
    if event.cursor_target ~= nil then
        hTarget = EntIndexToHScript(event.cursor_target)
    end

    if IsValid(hCaster) then
        player = hCaster:GetPlayerOwnerID()
    else
        return
    end

    if IsValid(ability) then
        if (AbilityBehaviorFilter(ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_NO_TARGET)) then

            if AbilityBehaviorFilter(ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_TOGGLE) then
                ExecuteOrderFromTable({
                    UnitIndex = hCaster:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TOGGLE,
                    AbilityIndex = event.ability,
                    Queue = false
                })
            else
                ExecuteOrderFromTable({
                    UnitIndex = hCaster:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                    AbilityIndex = event.ability,
                    Queue = false
                })
            end
        elseif (AbilityBehaviorFilter(ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)) then
            ExecuteOrderFromTable({
                UnitIndex = hCaster:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                TargetIndex = event.cursor_target,
                AbilityIndex = event.ability,
                Queue = false
            })
        elseif (AbilityBehaviorFilter(ability:GetBehaviorInt(), DOTA_ABILITY_BEHAVIOR_POINT)) then
            ExecuteOrderFromTable({
                UnitIndex = hCaster:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                Position = vPos,
                AbilityIndex = event.ability,
                Queue = false
            })
        end
    end

end

return Abilities_manager