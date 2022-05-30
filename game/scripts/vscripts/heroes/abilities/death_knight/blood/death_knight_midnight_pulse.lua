LinkLuaModifier( "modifier_death_knight_midnight_pulse", "heroes/abilities/death_knight/blood/death_knight_midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_midnight_pulse_buff", "heroes/abilities/death_knight/blood/death_knight_midnight_pulse.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_midnight_pulse == nil then
	death_knight_midnight_pulse = class({})
end
-- function death_knight_midnight_pulse:GetIntrinsicModifierName()
-- 	return "modifier_death_knight_midnight_pulse"
-- end
function death_knight_midnight_pulse:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local duration = self:GetSpecialValueFor("duration")

	EmitSoundOnLocationWithCaster(vPos, "Hero_Enigma.Midnight_Pulse", hCaster)
	CreateModifierThinker(hCaster, self, "modifier_death_knight_midnight_pulse", {duration = duration}, vPos, hCaster:GetTeamNumber(), false)

end
function death_knight_midnight_pulse:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
---------------------------------------------------------------------
--光环modifier
if modifier_death_knight_midnight_pulse == nil then
	modifier_death_knight_midnight_pulse = class({})
end
function modifier_death_knight_midnight_pulse:IsDebuff()
	return false
end
function modifier_death_knight_midnight_pulse:IsHidden()
	return true
end
function modifier_death_knight_midnight_pulse:IsPurgable()
	return false
end
function modifier_death_knight_midnight_pulse:IsAura()
	return true
end
function modifier_death_knight_midnight_pulse:GetModifierAura()
	return "modifier_death_knight_midnight_pulse_buff"
end
function modifier_death_knight_midnight_pulse:GetAuraRadius()
	return self.radius
end
function modifier_death_knight_midnight_pulse:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end
function modifier_death_knight_midnight_pulse:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end
function modifier_death_knight_midnight_pulse:GetAuraEntityReject(hEntity)
	return (hEntity ~= self:GetCaster())
end
function modifier_death_knight_midnight_pulse:OnCreated(params)
	self.damage_tick = self:GetAbility():GetSpecialValueFor("damage_tick")
	self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	local hCaster = self:GetCaster()
	if IsServer() then
		self:StartIntervalThink(self.damage_tick)
		self:OnIntervalThink()
	end

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/death_knight/death_knight_midnight_pulse.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particleID, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(particleID, 1, Vector(self.radius, 0, 0))
	self:AddParticle(particleID, false, false, -1, false, false)
	
end
function modifier_death_knight_midnight_pulse:OnIntervalThink()
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()
	local hAbility = self:GetAbility()
	if IsServer() then
		if hAbility == nil then
			self:Destroy()
		end
		local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hParent:GetAbsOrigin(), nil, self.radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= nil and enemy:IsAlive() then
				ApplyDamage({
					victim = enemy,
					attacker = hCaster,
					damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_AP) * self.ap_factor * 0.01,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self,
					damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
				})
			end
		end
	end

end
function modifier_death_knight_midnight_pulse:OnDestroy()
	if IsServer() then
	end
end
function modifier_death_knight_midnight_pulse:DeclareFunctions()
	return {
	}
end
--自身buffmodifier
if modifier_death_knight_midnight_pulse_buff == nil then
	modifier_death_knight_midnight_pulse_buff = class({})
end
function modifier_death_knight_midnight_pulse_buff:IsDebuff()
	return false
end
function modifier_death_knight_midnight_pulse_buff:IsHidden()
	return false
end
function modifier_death_knight_midnight_pulse_buff:IsPurgable()
	return false
end