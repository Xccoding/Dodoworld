LinkLuaModifier( "modifier_mage_kaya_array", "heroes/abilities/mage/common/mage_kaya_array.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mage_kaya_array_effect", "heroes/abilities/mage/common/mage_kaya_array.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mage_kaya_array == nil then
	mage_kaya_array = class({})
end
function mage_kaya_array:C_OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_DoomBringer.Doom", hCaster)

	CreateModifierThinker(hCaster, self, "modifier_mage_kaya_array", {duration = duration}, hCaster:GetAbsOrigin(), hCaster:GetTeamNumber(), false)
end
---------------------------------------------------------------------
--=======================================modifier_mage_kaya_array=======================================
if modifier_mage_kaya_array == nil then
	modifier_mage_kaya_array = class({})
end
function modifier_mage_kaya_array:IsHidden()
	return true
end
function modifier_mage_kaya_array:IsDebuff()
	return false
end
function modifier_mage_kaya_array:IsPurgable()
	return false
end
function modifier_mage_kaya_array:IsPurgeException()
	return false
end
function modifier_mage_kaya_array:GetAbilityValues()
	self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_mage_kaya_array:OnCreated(params)
	self:GetAbilityValues()
	if IsServer() then
		local hParent = self:GetParent()
		local particleID = ParticleManager:CreateParticle("particles/units/heroes/mage/mage_kaya_array.vpcf", PATTACH_CUSTOMORIGIN, hParent)
		ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
		self:AddParticle(particleID, false, false, -1, false, false)
	end
end
function modifier_mage_kaya_array:OnRefresh(params)
	self:GetAbilityValues()
end
function modifier_mage_kaya_array:OnDestroy(params)
end
function modifier_mage_kaya_array:DeclareFunctions()
	return {
	}
end
function modifier_mage_kaya_array:CDeclareFunctions()
	return {
	}
end
function modifier_mage_kaya_array:IsAura()
	return true
end
function modifier_mage_kaya_array:GetAuraRadius()
	return self.radius
end
function modifier_mage_kaya_array:GetAuraSearchFlags()
	local hAbility = self:GetAbility()
	return hAbility:GetAbilityTargetFlags()
end
function modifier_mage_kaya_array:GetAuraSearchTeam()
	local hAbility = self:GetAbility()
	return hAbility:GetAbilityTargetTeam()
end
function modifier_mage_kaya_array:GetAuraSearchType()
	local hAbility = self:GetAbility()
	return hAbility:GetAbilityTargetType()
end
function modifier_mage_kaya_array:GetModifierAura()
	return "modifier_mage_kaya_array_effect"
end
function modifier_mage_kaya_array:GetAuraEntityReject(entity)
	local hCaster = self:GetCaster()
	return entity ~= hCaster
end
function modifier_mage_kaya_array:GetAuraDuration()
	return 0
end
--=======================================modifier_mage_kaya_array_effect=======================================
if modifier_mage_kaya_array_effect == nil then
	modifier_mage_kaya_array_effect = class({})
end
function modifier_mage_kaya_array_effect:IsHidden()
	return false
end
function modifier_mage_kaya_array_effect:IsDebuff()
	return false
end
function modifier_mage_kaya_array_effect:IsPurgable()
	return false
end
function modifier_mage_kaya_array_effect:IsPurgeException()
	return false
end
function modifier_mage_kaya_array_effect:GetAbilityValues()
	self.bonus_magical_dmg_pct = self:GetAbilitySpecialValueFor("bonus_magical_dmg_pct")
end
function modifier_mage_kaya_array_effect:OnCreated(params)
	self:GetAbilityValues()
end
function modifier_mage_kaya_array_effect:OnRefresh(params)
	self:GetAbilityValues()
end
function modifier_mage_kaya_array_effect:OnDestroy(params)
end
function modifier_mage_kaya_array_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_mage_kaya_array_effect:CDeclareFunctions()
	return {
	}
end
function modifier_mage_kaya_array_effect:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.damage_type == DAMAGE_TYPE_MAGICAL then
        return self.bonus_magical_dmg_pct
    end
end
function modifier_mage_kaya_array_effect:OnTooltip()
	return self.bonus_magical_dmg_pct
end