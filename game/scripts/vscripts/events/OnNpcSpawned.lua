LinkLuaModifier( "modifier_common", "common/combat/modifiers/modifier_common.lua", LUA_MODIFIER_MOTION_NONE )

function DodoWorld:OnNpcSpawned( params )
    local unit = EntIndexToHScript(params.entindex)

    print('spawn')

    unit:AddNewModifier(unit, nil, "modifier_common", {})

    --给中立生物加施法监控
    if unit:IsNeutralUnitType() then
        unit:AddNewModifier(unit, nil, "modifier_channel_watcher", {})
    end

    if unit:IsHero() and unit:IsRealHero() then
        local new_schools = CustomNetTables:GetTableValue("hero_schools", tostring(unit:GetPlayerOwnerID())).schools_index
        RefreshAbilitiesToRole({entindex = params.entindex, new_schools = new_schools})
        unit:AutoUpgradeAbilities()
        unit:AddNewModifier(unit, nil, "modifier_hero_attribute", {})
        -- PlayerResource:SetOverrideSelectionEntity(unit:GetPlayerOwnerID(), unit)
    end    
end



