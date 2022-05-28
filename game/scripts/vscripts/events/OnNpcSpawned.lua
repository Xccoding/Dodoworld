LinkLuaModifier( "modifier_common", "common/combat/modifiers/modifier_common.lua", LUA_MODIFIER_MOTION_NONE )

function DodoWorld:OnNpcSpawned( params )
    local unit = EntIndexToHScript(params.entindex)

    print('spawn')

    unit:AddNewModifier(unit, nil, "modifier_common", {})

    if unit:IsHero() and unit:IsRealHero() then
        local new_schools = CustomNetTables:GetTableValue("hero_schools", tostring(params.entindex))
        unit:SetContextThink(DoUniqueString("RefreshAbilities"), function ()
            RefreshAbilitiesToRole({entindex = params.entindex, new_schools = new_schools})
            unit:AutoUpgradeAbilities()

            return nil
        end, 0.1)
        
    end    
end



