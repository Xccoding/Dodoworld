LinkLuaModifier( "modifier_mage_arcane_orb", "heroes/abilities/mage/arcane/mage_arcane_orb.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mage_arcane_orb == nil then
	mage_arcane_orb = class({})
end
function mage_arcane_orb:GetIntrinsicModifierName()
	return "modifier_mage_arcane_orb"
end
function mage_arcane_orb:GetManaCost(iLevel)
	local hCaster = self:GetCaster()
	local arcane_mana_cost_pct = self:GetSpecialValueFor("arcane_mana_cost_pct")
	local basic_mana_cost = self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
	if self:GetToggleState() == true then
		if self.arcane_stack ~= nil then
			return basic_mana_cost * ( 100 + arcane_mana_cost_pct * self.arcane_stack) * 0.01
		end
		return basic_mana_cost
	else
		return 0
	end
end
function mage_arcane_orb:OnToggle()
end
---------------------------------------------------------------------
--激活法球Modifiers
if modifier_mage_arcane_orb == nil then
	modifier_mage_arcane_orb = class({})
end
function modifier_mage_arcane_orb:IsHidden()
	return true
end
function modifier_mage_arcane_orb:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_mage_arcane_orb:IsPurgable()
	return false
end
function modifier_mage_arcane_orb:OnCreated(params)
	self.attack_range_override = self:GetAbilitySpecialValueFor("attack_range_override")
	self.attack_time_override = self:GetAbilitySpecialValueFor("attack_time_override")
	self.projectile_speed = self:GetAbilitySpecialValueFor("projectile_speed")
	self.damage_pct = self:GetAbilitySpecialValueFor("damage_pct")
	self.sp_factor = self:GetAbilitySpecialValueFor("sp_factor")
	self.mana_cost_pct = self:GetAbilitySpecialValueFor("mana_cost_pct")
	self.arcane_bonus_damage_pct = self:GetAbilitySpecialValueFor("arcane_bonus_damage_pct")
	self.arcane_bonus_attack_time = self:GetAbilitySpecialValueFor("arcane_bonus_attack_time")
	self.records = {}
end
function modifier_mage_arcane_orb:OnRefresh(params)
	self.attack_range_override = self:GetAbilitySpecialValueFor("attack_range_override")
	self.attack_time_override = self:GetAbilitySpecialValueFor("attack_time_override")
	self.projectile_speed = self:GetAbilitySpecialValueFor("projectile_speed")
	self.damage_pct = self:GetAbilitySpecialValueFor("damage_pct")
	self.sp_factor = self:GetAbilitySpecialValueFor("sp_factor")
	self.mana_cost_pct = self:GetAbilitySpecialValueFor("mana_cost_pct")
	self.arcane_bonus_damage_pct = self:GetAbilitySpecialValueFor("arcane_bonus_damage_pct")
	self.arcane_bonus_attack_time = self:GetAbilitySpecialValueFor("arcane_bonus_attack_time")
end
function modifier_mage_arcane_orb:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end
function modifier_mage_arcane_orb:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MAX_ATTACK_RANGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_RECORD,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
	}
end
function modifier_mage_arcane_orb:OnAttackLanded( params )
	if not IsServer() then
		return
	end
	if params.attacker == self:GetParent() then
		local hCaster = self:GetParent()
		local hTarget = params.target
		local hAbility = self:GetAbility()
		local arcane_buff = hCaster:FindModifierByName("modifier_mage_concussive_shot")
		local fDamage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * self.sp_factor * 0.01
		local equilibrium = hCaster:FindAbilityByName("mage_equilibrium")
		local equilibrium_pct = 0
		if hTarget:IsNull() or hTarget == nil or (not hTarget:IsAlive()) then
			return
		end
		if self:CheckUseOrb( params.record ) then
			EmitSoundOn("Hero_ObsidianDestroyer.ArcaneOrb.Impact", hTarget)
			if equilibrium ~= nil and equilibrium.equilibrium_pct ~= nil then
				equilibrium_pct = equilibrium.equilibrium_pct
			end
			if arcane_buff ~= nil then
				fDamage = fDamage * (100 + self.arcane_bonus_damage_pct * arcane_buff:GetStackCount() + equilibrium_pct) * 0.01
			end
			
			ApplyDamage({
					victim = hTarget,
					attacker = hCaster,
					damage = fDamage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = hAbility,
					damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
				})
		end
		

	end
end
function modifier_mage_arcane_orb:OnAttack( params )
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
			hCaster:SpendMana(hAbility:GetManaCost(), hAbility)
			--增加充能
			local arcane_buff = hCaster:FindModifierByName("modifier_mage_concussive_shot")
			if arcane_buff ~= nil then
				if arcane_buff:GetStackCount() < arcane_buff.max_stack then
					arcane_buff:IncrementStackCount()
				end
			end
		end
	end
end
function modifier_mage_arcane_orb:OnAttackRecord( params )
	if not IsServer() then
		return
	end
	if params.attacker == self:GetParent() then
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()

		if hAbility:GetToggleState() == true then
			if hCaster:GetMana() >= hAbility:GetManaCost() then
				table.insert( self.records, {iRecord = params.record, bOrb = true})
			end
		end
	end
end
function modifier_mage_arcane_orb:OnAttackRecordDestroy( params )
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
function modifier_mage_arcane_orb:GetModifierDamageOutgoing_Percentage()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return -self.damage_pct
	end
end
function modifier_mage_arcane_orb:GetModifierBaseAttackTimeConstant()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		if hAbility.arcane_stack ~= nil then
			return self.attack_time_override * (100 - hAbility.arcane_stack * self.arcane_bonus_attack_time) * 0.01
		end
		return self.attack_time_override
	end
end
function modifier_mage_arcane_orb:GetModifierAttackRangeOverride()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return self.attack_range_override
	end
end
function modifier_mage_arcane_orb:GetModifierMaxAttackRange()
	local hAbility = self:GetAbility()
	if hAbility:GetToggleState() == true then
		return self.attack_range_override
	end
end
function modifier_mage_arcane_orb:GetModifierProjectileName()
	local hCaster = self:GetCaster()
	local hAbility = self:GetAbility()
	if hCaster:GetMana() >= hAbility:GetManaCost() and hAbility:GetToggleState() == true then
		return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_arcane_orb.vpcf"
	end
end
function modifier_mage_arcane_orb:GetAttackSound()
	local hCaster = self:GetCaster()
	local hAbility = self:GetAbility()
	if hCaster:GetMana() >= hAbility:GetManaCost() and hAbility:GetToggleState() == true then
		return "Hero_ObsidianDestroyer.ArcaneOrb"
	end
end
function modifier_mage_arcane_orb:GetModifierProjectileSpeedBonus()
	local hCaster = self:GetCaster()
	local hAbility = self:GetAbility()
	if hCaster:GetMana() >= hAbility:GetManaCost() and hAbility:GetToggleState() == true then
		return self.projectile_speed
	end
end
function modifier_mage_arcane_orb:OnTooltip()
	return self:GetStackCount() * self.bonus_crit_chance
end
