LinkLuaModifier( "modifier_death_knight_flamethrower", "heroes/abilities/death_knight/frost/death_knight_flamethrower.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_flamethrower == nil then
	death_knight_flamethrower = class({})
end
function death_knight_flamethrower:GetManaCost(iLevel)
	local hCaster = self:GetCaster()
	local mana_cost_pct = self:GetSpecialValueFor("mana_cost_pct")

	return hCaster:GetMaxMana() * mana_cost_pct * 0.01
end
function death_knight_flamethrower:OnToggle()
	local hCaster = self:GetCaster()
	local hAbility = self
	if hAbility:GetToggleState() == true then
		hCaster:AddNewModifier(hCaster, hAbility, "modifier_death_knight_flamethrower", {})

		EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.Cast", hCaster)
	else
		hCaster:RemoveModifierByName("modifier_death_knight_flamethrower")
	end
end
function death_knight_flamethrower:ResetToggleOnRespawn()
	return true
end
---------------------------------------------------------------------
--Modifiers
if modifier_death_knight_flamethrower == nil then
	modifier_death_knight_flamethrower = class({})
end
function modifier_death_knight_flamethrower:IsPurgable()
	return false
end
function modifier_death_knight_flamethrower:OnCreated(params)
	self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
	self.distance = self:GetAbility():GetSpecialValueFor("distance")
	self.angle = self:GetAbility():GetSpecialValueFor("angle")
	self.mana_cost_pct =self:GetAbility():GetSpecialValueFor("mana_cost_pct")
	
	local hCaster = self:GetCaster()
	local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_flame_thrower.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
	self:AddParticle(particleID, false, false, -1, false, false)
	if IsServer() then
		self:StartIntervalThink(self.dot_interval)
		self:OnIntervalThink()
	end
end
function modifier_death_knight_flamethrower:OnRefresh(params)
	self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
	self.distance = self:GetAbility():GetSpecialValueFor("distance")
	self.angle = self:GetAbility():GetSpecialValueFor("angle")
	self.mana_cost_pct =self:GetAbility():GetSpecialValueFor("mana_cost_pct")
	if IsServer() then
		self:OnIntervalThink()
	end
end
function modifier_death_knight_flamethrower:OnIntervalThink()
	if IsServer() then
		local hCaster = self:GetCaster()
		local vFace = hCaster:GetForwardVector()
		local hAbility = self:GetAbility()
		local mana_cost = hCaster:GetMaxMana() * self.mana_cost_pct * 0.01

		local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, self.distance, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= nil and enemy:IsAlive() then
				local vToEnemy = (enemy:GetAbsOrigin() - hCaster:GetAbsOrigin()):Normalized()

				if AngleBetweenVectors(vFace, vToEnemy) < self.angle then
					ApplyDamage({
						victim = enemy,
						attacker = hCaster,
						damage = hCaster:GetDamageforAbility(true) * self.ap_factor * 0.01,
						damage_type = DAMAGE_TYPE_MAGICAL,
						ability = hAbility,
						damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
					})

					EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.projectileImpact", enemy)
				end

			end
		end

		if hCaster:GetMana() >= mana_cost then
			hCaster:SpendMana(mana_cost, hAbility)
			EmitSoundOn("Hero_Winter_Wyvern.ArcticBurn.attack", hCaster)
		else
			hAbility:ToggleAbility()
			self:Destroy()
			return
		end
		
	end
end
