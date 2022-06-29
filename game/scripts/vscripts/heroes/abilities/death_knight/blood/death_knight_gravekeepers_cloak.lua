LinkLuaModifier( "modifier_death_knight_gravekeepers_cloak", "heroes/abilities/death_knight/blood/death_knight_gravekeepers_cloak.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_gravekeepers_cloak_buff", "heroes/abilities/death_knight/blood/death_knight_gravekeepers_cloak.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_gravekeepers_cloak == nil then
	death_knight_gravekeepers_cloak = class({})
end
function death_knight_gravekeepers_cloak:GetIntrinsicModifierName()
	return "modifier_death_knight_gravekeepers_cloak"
end
function death_knight_gravekeepers_cloak:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("Hero_Abaddon.Curse.Proc", hCaster)
	
	hCaster:AddNewModifier(hCaster, self, "modifier_death_knight_gravekeepers_cloak_buff", {duration = duration})
end
---------------------------------------------------------------------
--被动叠层modifier
if modifier_death_knight_gravekeepers_cloak == nil then
	modifier_death_knight_gravekeepers_cloak = class({})
end
function modifier_death_knight_gravekeepers_cloak:IsDebuff()
	return false
end
function modifier_death_knight_gravekeepers_cloak:IsHidden()
	if self:GetStackCount() > 0 then
		return false
	else
		return true
	end
end
function modifier_death_knight_gravekeepers_cloak:IsPurgable()
	return false
end
function modifier_death_knight_gravekeepers_cloak:OnCreated(params)
	self.stack_per_tick = self:GetAbilitySpecialValueFor("stack_per_tick")
	self.cloak_cooldown = self:GetAbilitySpecialValueFor("cloak_cooldown")
	self.bonus_armor_str_factor = self:GetAbilitySpecialValueFor("bonus_armor_str_factor")
	self.max_stack = self:GetAbilitySpecialValueFor("max_stack")
	self.first_stack = self:GetAbilitySpecialValueFor("first_stack")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	self.fNext_stack_time = 0.00
	if IsServer() then
		self.IsInCombat = false
		self:StartIntervalThink(0)
	end
end
function modifier_death_knight_gravekeepers_cloak:OnRefresh(params)
	self.stack_per_tick = self:GetAbilitySpecialValueFor("stack_per_tick")
	self.cloak_cooldown = self:GetAbilitySpecialValueFor("cloak_cooldown")
	self.bonus_armor_str_factor = self:GetAbilitySpecialValueFor("bonus_armor_str_factor")
	self.max_stack = self:GetAbilitySpecialValueFor("max_stack")
	self.first_stack = self:GetAbilitySpecialValueFor("first_stack")
	self.bonus_attack_speed = self:GetAbilitySpecialValueFor("bonus_attack_speed")
	if IsServer() then
		self.IsInCombat = false
	end
end
function modifier_death_knight_gravekeepers_cloak:OnIntervalThink()
	local hCaster = self:GetCaster()
	local hAbility = self:GetAbility()
	local mana_get = self:GetAbilitySpecialValueFor("mana_get")
	if IsServer() then
		if hCaster:InCombat() then
			if GameRules:GetGameTime() >= self.fNext_stack_time and self:GetStackCount() < self.max_stack then

				if self:GetStackCount() <= 0 then
					self.cloak_particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_visage/visage_cloak_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
					--ParticleManager:SetParticleControlEnt(self.cloak_particle, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.cloak_particle, 2, Vector(1, 0, 0))
					ParticleManager:SetParticleControl(self.cloak_particle, 3, Vector(1, 0, 0))
					ParticleManager:SetParticleControl(self.cloak_particle, 4, Vector(1, 0, 0))
					ParticleManager:SetParticleControl(self.cloak_particle, 5, Vector(1, 0, 0))
				end

				--进战斗直接给9层
				if self.IsInCombat == false then
					self:SetStackCount(self:GetStackCount() + self.first_stack)
					hCaster:CGiveMana(mana_get, self, hCaster)
					self.IsInCombat = true
				else
					self:SetStackCount(self:GetStackCount() + self.stack_per_tick)
					hCaster:CGiveMana(mana_get, self, hCaster)
				end

				if self:GetStackCount() > self.max_stack then
					self:SetStackCount(self.max_stack)
				end
				
				-- hCaster:AddNewModifier(hCaster, hAbility, "modifier_death_knight_gravekeepers_cloak_passive", {count = self.stack_per_tick})
				self.fNext_stack_time = GameRules:GetGameTime() + self.cloak_cooldown
			end
		else
			self.IsInCombat = false
		end
	end

end
function modifier_death_knight_gravekeepers_cloak:OnDestroy()
	if IsServer() then
		if self.cloak_particle ~= nil then
			ParticleManager:DestroyParticle(self.cloak_particle, true)
			self.cloak_particle = nil
		end
	end
end
function modifier_death_knight_gravekeepers_cloak:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_death_knight_gravekeepers_cloak:CDeclareFunctions()
	return {
		CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT,
	}
end
function modifier_death_knight_gravekeepers_cloak:C_GetModifierPhysicalArmor_Constant()
	if self:GetStackCount() > 0 then
		return self.bonus_armor_str_factor * self:GetParent():GetStrength() * 0.01
	end
	return 0
end
function modifier_death_knight_gravekeepers_cloak:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount() > 0 then
		return self.bonus_attack_speed
	end
	return 0
end
function modifier_death_knight_gravekeepers_cloak:OnAttackLanded( params )
	if not IsServer() then
		return
	end
	if params.target == self:GetParent() then
		if self:GetStackCount() > 0 then
			if not params.ranged_attack then
				self:DecrementStackCount()
				if self:GetStackCount() <= 0 then
					ParticleManager:DestroyParticle(self.cloak_particle, true)
				end
			end
		end
	end
end
--主动开启modifier
if modifier_death_knight_gravekeepers_cloak_buff == nil then
	modifier_death_knight_gravekeepers_cloak_buff = class({})
end
function modifier_death_knight_gravekeepers_cloak_buff:IsDebuff()
	return false
end
function modifier_death_knight_gravekeepers_cloak_buff:IsHidden()
	return false
end
function modifier_death_knight_gravekeepers_cloak_buff:IsPurgable()
	return false
end
function modifier_death_knight_gravekeepers_cloak_buff:OnCreated(params)
	self.incoming_damage_pct = self:GetAbilitySpecialValueFor("incoming_damage_pct")
end
function modifier_death_knight_gravekeepers_cloak_buff:OnRefresh(params)
	self.incoming_damage_pct = self:GetAbilitySpecialValueFor("incoming_damage_pct")
end
function modifier_death_knight_gravekeepers_cloak_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end
function modifier_death_knight_gravekeepers_cloak_buff:GetModifierIncomingDamage_Percentage()
	return -self.incoming_damage_pct
end
function modifier_death_knight_gravekeepers_cloak_buff:GetEffectName()
	return "particles/units/heroes/death_knight/death_knight_gravekeepers_cloak_buffstack.vpcf"
end
function modifier_death_knight_gravekeepers_cloak_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end