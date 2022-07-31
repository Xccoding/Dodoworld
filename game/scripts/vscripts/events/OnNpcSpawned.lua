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
        Abilities_manager:RefreshAbilitiesToRole({entindex = params.entindex, new_schools = new_schools})
        Abilities_manager:AutoUpgradeAbilities(unit)
        unit:AddNewModifier(unit, nil, "modifier_hero_attribute", {})
        
        unit:SetContextThink("123", function ()
            AddFOWViewer(unit:GetTeamNumber(), unit:GetAbsOrigin(), 999999, 100, false)
        end, 2)
        -- PlayerResource:SetOverrideSelectionEntity(unit:GetPlayerOwnerID(), unit)
    else
        if unit.kv_attr_table ~= nil then
            unit:AddNewModifier(unit, nil, "modifier_basic_attribute", unit.kv_attr_table)
            unit.kv_attr_table = nil
        end
    end    
end



