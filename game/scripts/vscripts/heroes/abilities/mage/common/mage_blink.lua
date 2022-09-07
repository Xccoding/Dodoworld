--=======================================mage_blink=======================================
if mage_blink == nil then
    mage_blink = class({})
end
function mage_blink:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_blink:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local distance = self:GetSpecialValueFor("distance")
    local dir = hCaster:GetForwardVector()
    local start_pos = hCaster:GetAbsOrigin()
    local end_pos = hCaster:GetAbsOrigin()

    EmitSoundOnLocationWithCaster(start_pos, "Hero_Antimage.Blink_out", hCaster)

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(particleID, 0, start_pos)
    ParticleManager:SetParticleControlEnt(particleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    ParticleManager:ReleaseParticleIndex(particleID)

    for i = 1, distance do
        if GridNav:CanFindPath(start_pos, end_pos + dir * 1) then
            end_pos = end_pos + dir * 1
        else
           break 
        end
    end

    FindClearSpaceForUnit(hCaster, end_pos, true)
    EmitSoundOnLocationWithCaster(end_pos, "Hero_Antimage.Blink_in", hCaster)

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(particleID, 0, end_pos)
    ParticleManager:SetParticleControlEnt(particleID, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true)
    ParticleManager:ReleaseParticleIndex(particleID)
    
end