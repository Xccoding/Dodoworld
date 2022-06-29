if  neutral_creep_track == nil then
    neutral_creep_track = class({})
end
LinkLuaModifier( "modifier_neutral_creep_track", "units/abilities/neutral/neutral_creep_track.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function neutral_creep_track:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    EmitSoundOn("Hero_BountyHunter.Target", hTarget)
    hTarget:AddNewModifier(hCaster, self, "modifier_neutral_creep_track", {duration = duration})
end
--modifier
if modifier_neutral_creep_track == nil then
	modifier_neutral_creep_track = class({})
end
function modifier_neutral_creep_track:IsHidden()
    return false
end
function modifier_neutral_creep_track:IsDebuff()
    return true
end 
function modifier_neutral_creep_track:IsPurgable()
    return true
end
function modifier_neutral_creep_track:GetEffectName()
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf"
end
function modifier_neutral_creep_track:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_neutral_creep_track:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
	}
	return state
end
function modifier_neutral_creep_track:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end
function modifier_neutral_creep_track:CDeclareFunctions()
	local funcs = {
		CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT,
	}
	return funcs
end
function modifier_neutral_creep_track:C_GetModifierPhysicalArmor_Constant()
	return -self.armor_reduce
end
function modifier_neutral_creep_track:GetModifierProvidesFOWVision()
	return 1
end
function modifier_neutral_creep_track:OnCreated(params)
    self.armor_reduce = self:GetAbilitySpecialValueFor("armor_reduce")
end
function modifier_neutral_creep_track:OnRefresh(params)
    self.armor_reduce = self:GetAbilitySpecialValueFor("armor_reduce")
end
function modifier_neutral_creep_track:OnTooltip()
	return -self.armor_reduce
end