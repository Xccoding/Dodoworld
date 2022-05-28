LinkLuaModifier( "modifier_death_knight_borrowed_time", "heroes/abilities/death_knight/blood/death_knight_borrowed_time.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_borrowed_time == nil then
	death_knight_borrowed_time = class({})
end
function death_knight_borrowed_time:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local hp_factor = self:GetSpecialValueFor("hp_factor")

	EmitSoundOn("Hero_Abaddon.BorrowedTime", hCaster)
	
	hCaster:AddNewModifier(hCaster, self, "modifier_death_knight_borrowed_time", {duration = duration, shield = hp_factor * hCaster:GetMaxHealth() * 0.01})
end
--主动开启modifier
if modifier_death_knight_borrowed_time == nil then
	modifier_death_knight_borrowed_time = class({})
end
function modifier_death_knight_borrowed_time:IsDebuff()
	return false
end
function modifier_death_knight_borrowed_time:IsHidden()
	return false
end
function modifier_death_knight_borrowed_time:IsPurgable()
	return false
end
function modifier_death_knight_borrowed_time:OnCreated(params)
	self.bonus_status_resistance = self:GetAbility():GetSpecialValueFor("bonus_status_resistance")
	if IsServer() then
		self.shield = params.shield
		self:SetStackCount(self.shield)
	end
end
function modifier_death_knight_borrowed_time:OnRefresh(params)
	self.bonus_status_resistance = self:GetAbility():GetSpecialValueFor("bonus_status_resistance")
	if IsServer() then
		self.shield = self.shield + params.shield
		self:SetStackCount(self.shield)
	end
end
function modifier_death_knight_borrowed_time:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end
function modifier_death_knight_borrowed_time:GetModifierStatusResistance()
	return self.bonus_status_resistance
end
function modifier_death_knight_borrowed_time:GetModifierTotal_ConstantBlock(params)
	if params.damage_type == DAMAGE_TYPE_MAGICAL then
        local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()

		if IsServer() then
			if params.damage >= self.shield then
				hCaster:CHeal(self.shield, hAbility, false, true, hCaster, false)
				self:Destroy()
				return self.shield
			else
				self.shield = self.shield - params.damage
				self:SetStackCount(self.shield)
				hCaster:CHeal(params.damage, hAbility, false, true, hCaster, false)
				return params.damage
			end
		end
    end
end
function modifier_death_knight_borrowed_time:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
end
function modifier_death_knight_borrowed_time:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_death_knight_borrowed_time:GetStatusEffectName()
	return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf"
end
function modifier_death_knight_borrowed_time:StatusEffectPriority()
	return 2
end