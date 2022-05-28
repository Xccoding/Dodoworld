if  death_knight_reality_rift == nil then
    death_knight_reality_rift = class({})
end

--ability
function death_knight_reality_rift:OnAbilityPhaseStart()
    local hCaster = self:GetCaster()
    return true
end
function death_knight_reality_rift:OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()
    return true
end
function death_knight_reality_rift:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()

    EmitSoundOn("Hero_ChaosKnight.RealityRift", hCaster)
    
    if IsServer() then
        self:pull(hTarget)

        -- local count = 0
        -- local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, search_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        -- for _, enemy in pairs(enemies) do
        --     if enemy ~= nil and enemy:IsAlive() and enemy ~= hTarget then
        --         self:blast(enemy)
        --         count = count + 1
        --         if count >= bonus_target_count then
        --             break
        --         end
        --     end
        -- end
    end
end
function death_knight_reality_rift:pull(hTarget)
    local hCaster = self:GetCaster()
    local vPos = hCaster:GetAbsOrigin() + hCaster:GetForwardVector():Normalized() * 200
    local duration = self:GetSpecialValueFor("duration")

    FindClearSpaceForUnit(hTarget, vPos, true)
    hTarget:Interrupt()
    local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_reality_rift.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), false)
    ParticleManager:SetParticleControlEnt(particleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), false)
    ParticleManager:SetParticleControl(particleID, 2, vPos)
    ParticleManager:ReleaseParticleIndex(particleID)

    EmitSoundOn("Hero_ChaosKnight.RealityRift.Target", hTarget)

    hTarget:AddNewModifier(hCaster, self, "modifier_taunt_custom", {duration = duration})

end

