if Abilities_manager == nil then
    Abilities_manager = {}
end

function Abilities_manager:InitSchools()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        CustomNetTables:SetTableValue("hero_schools", tostring(playerID), {schools_index = 0})
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

    local abilities_to_add = KeyValues.RoleAbilities[unit:GetUnitLabel().."_schools_"..tostring(new_schools)]
    if abilities_to_add ~= nil then
        for i = 1, 6 do
            if abilities_to_add["Ability"..i] ~= nil then
                local add_ability = unit:AddAbility(abilities_to_add["Ability"..tostring(i)])
                add_ability:SetAbilityIndex(i - 1)
                -- unit:SetAbilityByIndex(add_ability, i)
            end
        end
    
        --更新网表
        CustomNetTables:SetTableValue("hero_schools", tostring(unit:GetPlayerOwnerID()), {schools_index = new_schools})
        -- for i = MIN_ABILITY_SLOT, MAX_ABILITY_SLOT do
        --     if unit:GetAbilityByIndex(i) ~= nil then
        --         print(unit:GetAbilityByIndex(i):GetAbilityName())
        --     end
        -- end
    end
 
end

function Abilities_manager:AutoUpgradeAbilities( hero )
    if hero == nil then
        return
    end
    for i = MIN_ABILITY_SLOT, MAX_ABILITY_SLOT do
        local hAbility = hero:GetAbilityByIndex(i)
        if hAbility ~= nil then
            local abilty_levels = Abilities_Required_Level[hAbility:GetAbilityName()]
            if abilty_levels ~= nil then
                for index = #abilty_levels, 1, -1 do
                    if hero:GetLevel() >= abilty_levels[index] then
                        hAbility:SetLevel(index)
                        break
                    end
                end
            end
        end
    end
end

return Abilities_manager