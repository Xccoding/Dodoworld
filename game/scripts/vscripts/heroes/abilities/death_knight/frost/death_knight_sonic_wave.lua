LinkLuaModifier( "modifier_death_knight_sonic_wave", "heroes/abilities/death_knight/frost/death_knight_sonic_wave.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_sonic_wave == nil then
	death_knight_sonic_wave = class({})
end
function death_knight_sonic_wave:OnSpellStart()
	local hCaster = self:GetCaster()
	local hAbility = self
	local vPos = self:GetCursorPosition()
	local vDir = (vPos - hCaster:GetAbsOrigin()):Normalized()
	local distance = self:GetSpecialValueFor("distance")
	local width_start = self:GetSpecialValueFor("width_start")
	local width_end = self:GetSpecialValueFor("width_end")
	local speed = self:GetSpecialValueFor("speed")

	local info = {
		Ability = hAbility,
		Source = hCaster,
		EffectName = "particles/units/heroes/death_knight/death_knight_sonic_wave.vpcf",
		vSpawnOrigin = hCaster:GetAbsOrigin(),
		vVelocity = vDir * speed,
		fDistance = distance,
		fStartRadius = width_start,
		fEndRadius = width_end,
		iUnitTargetTeam = hAbility:GetAbilityTargetTeam(),
		iUnitTargetType = hAbility:GetAbilityTargetType(),
		iUnitTargetFlags = hAbility:GetAbilityTargetFlags(),
	}
	ProjectileManager:CreateLinearProjectile(info)

	EmitSoundOn("Hero_QueenOfPain.SonicWave", hCaster)
	EmitSoundOn("Hero_QueenOfPain.SonicWave.ArcanaLayer", hCaster)
end
function death_knight_sonic_wave:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil then
		local hCaster = self:GetCaster()
		local hAbility = self
		local ap_factor = self:GetSpecialValueFor("ap_factor")
		local duration = self:GetSpecialValueFor("duration")

		ApplyDamage({
            victim = hTarget,
            attacker = hCaster,
            damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_AP) * ap_factor * 0.01,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = hAbility,
            damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
        })

		if hTarget:IsAlive() then
			hTarget:AddNewModifier(hCaster, hAbility, "modifier_death_knight_sonic_wave", {duration = duration})
		end

		EmitSoundOn("Hero_QueenOfPain.SonicWave.Arcana.Target", hTarget)

	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_death_knight_sonic_wave == nil then
	modifier_death_knight_sonic_wave = class({})
end
function modifier_death_knight_sonic_wave:OnCreated(params)
	self.slow_down_pct = self:GetAbilitySpecialValueFor("slow_down_pct")
	if IsServer() then
	end
end
function modifier_death_knight_sonic_wave:OnRefresh(params)
	self.slow_down_pct = self:GetAbilitySpecialValueFor("slow_down_pct")
	if IsServer() then
	end
end
function modifier_death_knight_sonic_wave:OnDestroy()
	if IsServer() then
	end
end
function modifier_death_knight_sonic_wave:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_death_knight_sonic_wave:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow_down_pct
end