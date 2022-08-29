LinkLuaModifier( "modifier_mage_flame_cloak_buff", "heroes/abilities/mage/fire/mage_flame_cloak.lua", LUA_MODIFIER_MOTION_NONE )

--Abilities
if mage_flame_cloak == nil then
	mage_flame_cloak = class({})
end
function mage_flame_cloak:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	hCaster:AddNewModifier(hCaster, self, "modifier_mage_flame_cloak_buff", {duration = duration})
	EmitSoundOn("Hero_Lina.FlameCloak.Cast", hCaster)
end
---------------------------------------------------------------------
--燃烧Modifiers
if modifier_mage_flame_cloak_buff == nil then
	modifier_mage_flame_cloak_buff = class({})
end
function modifier_mage_flame_cloak_buff:IsDebuff()
	return false
end
function modifier_mage_flame_cloak_buff:IsHidden()
	return false
end
function modifier_mage_flame_cloak_buff:IsPurgable()
	return false
end
function modifier_mage_flame_cloak_buff:OnCreated(params)
	self.bonus_magical_crit_chance = self:GetAbilitySpecialValueFor("bonus_magical_crit_chance")
	if IsServer() then
		local hCaster = self:GetCaster()
		local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_flame_cloak.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
		ParticleManager:SetParticleControlEnt(particleID, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_mage_flame_cloak_buff:OnRefresh(params)
	self.bonus_magical_crit_chance = self:GetAbilitySpecialValueFor("bonus_magical_crit_chance")
	if IsServer() then
	end
end
function modifier_mage_flame_cloak_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_lina_flame_cloak.vpcf" 
end
function modifier_mage_flame_cloak_buff:StatusEffectPriority()
	return 3
end
function modifier_mage_flame_cloak_buff:CDeclareFunctions()
	return {
		CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT,
	}
end
function modifier_mage_flame_cloak_buff:C_GetModifierBonusMagicalCritChance_Percent( params )
	return self.bonus_magical_crit_chance
end
