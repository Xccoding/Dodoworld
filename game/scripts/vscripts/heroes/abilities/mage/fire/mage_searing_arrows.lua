LinkLuaModifier( "modifier_mage_searing_arrows", "heroes/abilities/mage/fire/mage_searing_arrows.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mage_searing_arrows_passive", "heroes/abilities/mage/fire/mage_searing_arrows.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mage_searing_arrows == nil then
	mage_searing_arrows = class({})
end
function mage_searing_arrows:GetIntrinsicModifierName()
	return "modifier_mage_searing_arrows"
end
function mage_searing_arrows:OnToggle()

end
---------------------------------------------------------------------
--Modifiers
if modifier_mage_searing_arrows == nil then
	modifier_mage_searing_arrows = class({})
end
function modifier_mage_searing_arrows:IsPurgable()
	return false
end
function modifier_mage_searing_arrows:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_mage_searing_arrows:OnCreated(params)
	self.attack_range_override = self:GetAbility():GetSpecialValueFor("attack_range_override")
	self.attack_time_override = self:GetAbility():GetSpecialValueFor("attack_time_override")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct")
	self.sp_factor = self:GetAbility():GetSpecialValueFor("sp_factor")
	self.bonus_crit_chance = self:GetAbility():GetSpecialValueFor("bonus_crit_chance")
	self.records = {}
end
function modifier_mage_searing_arrows:OnRefresh(params)
	self.attack_range_override = self:GetAbility():GetSpecialValueFor("attack_range_override")
	self.attack_time_override = self:GetAbility():GetSpecialValueFor("attack_time_override")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct")
	self.sp_factor = self:GetAbility():GetSpecialValueFor("sp_factor")
	self.bonus_crit_chance = self:GetAbility():GetSpecialValueFor("bonus_crit_chance")
end
function modifier_mage_searing_arrows:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
function modifier_mage_searing_arrows:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MAX_ATTACK_RANGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_mage_searing_arrows:OnAttackRecord( params )
	if not IsServer() then
		return
	end
	if params.attacker == self:GetParent() then
		local hAbility = self:GetAbility()
		if hAbility:GetToggleState() == true then
			table.insert( self.records, {iRecord = params.record, bOrb = true})
		end
	end
end
function modifier_mage_searing_arrows:OnAttackRecordDestroy( params )
	if not IsServer() then
		return
	end
	if params.attacker == self:GetParent() then
		for i = 1, #self.records do
			if self.records[i] ~= nil then
				if self.records[i].iRecord ~= nil and params.record ~= nil then
					if self.records[i].iRecord == params.record then
						table.remove(self.records, i)
					end
				end
			else
				table.remove(self.records, i)
			end
		end
	end
end
function modifier_mage_searing_arrows:OnAttackLanded( params )
	if not IsServer() then
		return
	end
	if params.attacker == self:GetParent() then
		local hCaster = self:GetParent()
		local hTarget = params.target
		local hAbility = self:GetAbility()
		if hTarget:IsNull() or hTarget == nil or (not hTarget:IsAlive()) then
			return
		end
		if self:CheckUseOrb( params.record ) then
			EmitSoundOn("Hero_Clinkz.SearingArrows.Impact", hTarget)

			ApplyDamage({
					victim = hTarget,
					attacker = hCaster,
					damage = hCaster:GetDamageforAbility(false) * self.sp_factor * 0.01,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = hAbility,
					damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
				})
		end
	end
end
function modifier_mage_searing_arrows:GetModifierDamageOutgoing_Percentage()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return -self.damage_pct
	end
end
function modifier_mage_searing_arrows:GetModifierBaseAttackTimeConstant()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return self.attack_time_override
	end
end
function modifier_mage_searing_arrows:GetModifierAttackRangeOverride()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return self.attack_range_override
	end
end
function modifier_mage_searing_arrows:GetModifierMaxAttackRange()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return self.attack_range_override
	end
end
function modifier_mage_searing_arrows:GetModifierProjectileName()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"
	end
end
function modifier_mage_searing_arrows:GetAttackSound()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return "Hero_Clinkz.SearingArrows"
	end
end
function modifier_mage_searing_arrows:CDeclareFunctions()
	return {
		CMODIFIER_EVENT_ON_SPELL_CRIT,
		CMODIFIER_EVENT_ON_SPELL_NOTCRIT,
		CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT,
	}	
end
function modifier_mage_searing_arrows:C_OnSpellCrit(params)
	if not IsServer() then
		return
	end
	if params.inflictor ~= nil and params.inflictor == self:GetAbility() and params.attacker == self:GetParent() then
		self:SetStackCount(0)
	end
end
function modifier_mage_searing_arrows:C_OnSpellNotCrit(params)
	if not IsServer() then
		return
	end
	if params.inflictor ~= nil and params.inflictor == self:GetAbility() and params.attacker == self:GetParent() then
		self:IncrementStackCount()
	end
end
function modifier_mage_searing_arrows:C_GetModifierBonusMagicalCritChance_Constant( params )
	if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
		return self:GetStackCount() * self.bonus_crit_chance
	else
		return 0
	end
end
function modifier_mage_searing_arrows:OnTooltip()
	return self:GetStackCount() * self.bonus_crit_chance
end
