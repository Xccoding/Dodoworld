LinkLuaModifier( "modifier_death_knight_bulldoze", "heroes/abilities/death_knight/frost/death_knight_bulldoze.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_bulldoze_passive", "heroes/abilities/death_knight/frost/death_knight_bulldoze.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_bulldoze == nil then
	death_knight_bulldoze = class({})
end
function death_knight_bulldoze:GetIntrinsicModifierName()
	return "modifier_death_knight_bulldoze_passive"
end
function death_knight_bulldoze:OnSpellStart()
	local hCaster = self:GetCaster()
	local hAbility = self
	local duration = self:GetSpecialValueFor("duration")

	hCaster:AddNewModifier(hCaster, hAbility, "modifier_death_knight_bulldoze", {duration = duration})

	EmitSoundOn("Hero_Spirit_Breaker.Bulldoze.Cast", hCaster)
end
---------------------------------------------------------------------
--冰柱Modifiers
if modifier_death_knight_bulldoze == nil then
	modifier_death_knight_bulldoze = class({})
end
function modifier_death_knight_bulldoze:OnCreated(params)
	self.bonus_str_pct = self:GetAbility():GetSpecialValueFor("bonus_str_pct")
    self.bonus_str_stack_pct = self:GetAbility():GetSpecialValueFor("bonus_str_stack_pct")
	self.stack_others = self:GetAbility():GetSpecialValueFor("stack_others")
	self.bonus_str = self:GetParent():GetStrength() * self.bonus_str_pct * 0.01
	self:SetStackCount(0)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end
function modifier_death_knight_bulldoze:OnRefresh(params)
	self.bonus_str_pct = self:GetAbility():GetSpecialValueFor("bonus_str_pct")
    self.bonus_str_stack_pct = self:GetAbility():GetSpecialValueFor("bonus_str_stack_pct")
	self.stack_others = self:GetAbility():GetSpecialValueFor("stack_others")
end
function modifier_death_knight_bulldoze:OnIntervalThink()
	if IsServer() then
		self.bonus_str = self:GetParent():GetStrength() * (self.bonus_str_pct + self.bonus_str_stack_pct * self:GetStackCount()) * 0.01
		self:GetParent():CalculateStatBonus(true)
	end
end
function modifier_death_knight_bulldoze:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_death_knight_bulldoze:GetEffectName()
	return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf"
end
function modifier_death_knight_bulldoze:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_death_knight_bulldoze:GetModifierBonusStats_Strength()
	return self.bonus_str
end
function modifier_death_knight_bulldoze:OnTooltip()
	return self.bonus_str_pct + self.bonus_str_stack_pct * self:GetStackCount()
end
function modifier_death_knight_bulldoze:OnAbilityFullyCast( params )
	if params.unit == self:GetParent() then
		local hCaster = params.unit
		local hAbility = params.ability

		if IsServer() then
			if hAbility:GetAbilityName() == "death_knight_frost_nova" or hAbility:GetAbilityName() == "death_knight_frost_shield" then
				self:SetStackCount(self:GetStackCount() + self.stack_others)
			end
		end
	end
end
function modifier_death_knight_bulldoze:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
	}
end
--精通Modifiers
if modifier_death_knight_bulldoze_passive == nil then
	modifier_death_knight_bulldoze_passive = class({})
end
function modifier_death_knight_bulldoze_passive:OnCreated(params)
	self.str_factor = self:GetAbility():GetSpecialValueFor("str_factor")
	self.bonus_magic_damage_pct = 0
	self:SetStackCount(0)
	self:StartIntervalThink(0)
end
function modifier_death_knight_bulldoze_passive:OnRefresh(params)
	self.str_factor = self:GetAbility():GetSpecialValueFor("str_factor")
end
function modifier_death_knight_bulldoze_passive:OnIntervalThink()
	self.bonus_magic_damage_pct = self:GetCaster():GetStrength() * self.str_factor * 0.01
end
function modifier_death_knight_bulldoze_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_death_knight_bulldoze_passive:GetModifierTotalDamageOutgoing_Percentage( params )
	if params.damage_type == DAMAGE_TYPE_MAGICAL then
		return self.bonus_magic_damage_pct
	end
end
function modifier_death_knight_bulldoze_passive:OnTooltip()
	return self.bonus_magic_damage_pct
end