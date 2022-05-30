LinkLuaModifier( "modifier_neutral_creep_envenomed_weapon", "units/abilities/neutral/neutral_creep_envenomed_weapon.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_neutral_creep_envenomed_weapon_debuff", "units/abilities/neutral/neutral_creep_envenomed_weapon.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if neutral_creep_envenomed_weapon == nil then
	neutral_creep_envenomed_weapon = class({})
end
function neutral_creep_envenomed_weapon:GetIntrinsicModifierName()
	return "modifier_neutral_creep_envenomed_weapon"
end
---------------------------------------------------------------------
--Modifier1
if modifier_neutral_creep_envenomed_weapon == nil then
	modifier_neutral_creep_envenomed_weapon = class({})
end
function modifier_neutral_creep_envenomed_weapon:IsHidden()
	return true
end
function modifier_neutral_creep_envenomed_weapon:OnCreated(params)
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end
function modifier_neutral_creep_envenomed_weapon:OnRefresh(params)
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
end
function modifier_neutral_creep_envenomed_weapon:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_neutral_creep_envenomed_weapon:OnAttackLanded( params )
	if params.attacker == self:GetCaster() then
		local hAbility = self:GetAbility()
		local hCaster = self:GetCaster()
		local hTarget = params.target
		if hAbility:IsCooldownReady() then
			hTarget:AddNewModifier(hCaster, hAbility, "modifier_neutral_creep_envenomed_weapon_debuff", {duration = self.duration})
			hAbility:StartCooldown(hAbility:GetCooldown(hAbility:GetLevel()))
		end
	end
end
--Modifier2
if modifier_neutral_creep_envenomed_weapon_debuff == nil then
	modifier_neutral_creep_envenomed_weapon_debuff = class({})
end
function modifier_neutral_creep_envenomed_weapon_debuff:IsPurgable()
	return true
end
function modifier_neutral_creep_envenomed_weapon_debuff:OnCreated(params)
	self.miss_pct = self:GetAbility():GetSpecialValueFor("miss_pct")
	self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
	if IsServer() then
		self:StartIntervalThink(self.dot_interval)
	end
end
function modifier_neutral_creep_envenomed_weapon_debuff:OnRefresh(params)
	self.miss_pct = self:GetAbility():GetSpecialValueFor("miss_pct")
	self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
end
function modifier_neutral_creep_envenomed_weapon_debuff:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()
		local hAbility = self:GetAbility()
		ApplyDamage({
				victim = hParent,
				attacker = hCaster,
				damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_AP) * self.ap_factor * 0.01,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = hAbility,
				damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
			})
	end
end
function modifier_neutral_creep_envenomed_weapon_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
end
function modifier_neutral_creep_envenomed_weapon_debuff:GetModifierMiss_Percentage()
	return self.miss_pct
end
function modifier_neutral_creep_envenomed_weapon_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_neutral_creep_envenomed_weapon_debuff:GetEffectName()
	return "particles/neutral_fx/gnoll_poison_debuff.vpcf"
end