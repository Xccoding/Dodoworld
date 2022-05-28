if  mage_laguna_blade == nil then
    mage_laguna_blade = class({})
end
--ability
function mage_laguna_blade:GetCastAnimation()
	local hCaster = self:GetCaster()
	if hCaster:GetUnitName() == "npc_dota_hero_lina" then
		return ACT_DOTA_CAST_ABILITY_4
	elseif hCaster:GetUnitName() == "npc_dota_hero_silencer" then
		return ACT_DOTA_CAST_ABILITY_3
	end
end
function mage_laguna_blade:GetBehavior()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return tonumber(tostring(self.BaseClass.GetBehavior(self))) + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
	return tonumber(tostring(self.BaseClass.GetBehavior(self)))
end
function mage_laguna_blade:GetAbilityTextureName()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return  "mage_laguna_blade"
    else
        return  "lina_laguna_blade"
    end
end
function mage_laguna_blade:OnAbilityPhaseStart()
    local hCaster = self:GetCaster()
	EmitSoundOnEntityForPlayer("Hero_StormSpirit.ElectricVortex", hCaster, hCaster:GetPlayerOwnerID())
    self.particleID_pre = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
    ParticleManager:SetParticleControlEnt(self.particleID_pre, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(self.particleID_pre, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0, 0, 0), false)
    return true
end
function mage_laguna_blade:OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()
	StopSoundOn("Hero_StormSpirit.ElectricVortex", hCaster)
    ParticleManager:DestroyParticle(self.particleID_pre, true)
    self.particleID_pre = nil
    return true
end
function mage_laguna_blade:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local flags = DOTA_DAMAGE_FLAG_DIRECT

    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        flags = flags + DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO
		hCaster:RemoveModifierByName("modifier_mage_fiery_soul_combo")
	end

    StopSoundOn("Hero_StormSpirit.ElectricVortex", hCaster)
    if self.particleID_pre ~= nil then
        ParticleManager:DestroyParticle(self.particleID_pre, true)
    end
	self.particleID_pre = nil
    local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_ABSORIGIN, hTarget)
    ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:ReleaseParticleIndex(iParticleID)

    EmitSoundOn("Ability.LagunaBlade", hCaster)
    EmitSoundOn("Ability.LagunaBladeImpact", hTarget)
    
    ApplyDamage(
        {
            victim = hTarget,
			attacker = hCaster,
			damage = hCaster:GetDamageforAbility(false) * sp_factor * 0.01,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
			damage_flags = flags,
        }
    )


end

