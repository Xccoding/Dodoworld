LinkLuaModifier( "modifier_mage_light_strike_array", "heroes/abilities/mage/fire/mage_light_strike_array.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if mage_light_strike_array == nil then
	mage_light_strike_array = class({})
end
function mage_light_strike_array:GetCastAnimation()
	local hCaster = self:GetCaster()
	if hCaster:GetUnitName() == "npc_dota_hero_lina" then
		return ACT_DOTA_CAST_ABILITY_2
	elseif hCaster:GetUnitName() == "npc_dota_hero_silencer" then
		return ACT_DOTA_CAST_ABILITY_1
	end
end
function mage_light_strike_array:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end
-- function mage_light_strike_array:GetBehavior()
-- 	local hCaster = self:GetCaster()
--     if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
--         return tonumber(tostring(self.BaseClass.GetBehavior(self))) + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
--     end
-- 	return tonumber(tostring(self.BaseClass.GetBehavior(self)))
-- end
function mage_light_strike_array:GetCastPoint()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return 0
    end
    return tonumber(tostring(self.BaseClass.GetCastPoint(self)))
end
function mage_light_strike_array:GetPlaybackRateOverride()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return 1000
    end
    return tonumber(tostring(self.BaseClass.GetPlaybackRateOverride(self)))
end
function mage_light_strike_array:GetAbilityTextureName()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return  "mage_light_strike_array"
    else
        return  "lina_light_strike_array"
    end
end
function mage_light_strike_array:OnAbilityPhaseStart()
	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	if not hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        EmitSoundOnEntityForPlayer("Hero_Invoker.SunStrike.Charge", hCaster, hCaster:GetPlayerOwnerID())
    end
	self.particleID_pre = ParticleManager:CreateParticleForPlayer("particles/units/heroes/mage/mage_light_strike_array_ray_team.vpcf", PATTACH_CUSTOMORIGIN, hCaster, hCaster:GetPlayerOwner())
	ParticleManager:SetParticleControl(self.particleID_pre, 0, vPos)
	ParticleManager:SetParticleControl(self.particleID_pre, 1, Vector(radius, 0, 0))

	return true
end
function mage_light_strike_array:OnAbilityPhaseInterrupted()
	local hCaster = self:GetCaster()
	StopSoundOn("Hero_Invoker.SunStrike.Charge", hCaster)
	ParticleManager:DestroyParticle(self.particleID_pre, true)
	self.particleID_pre = nil
	return true
end
function mage_light_strike_array:OnSpellStart()
	local hCaster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local sp_factor = self:GetSpecialValueFor("sp_factor")
	local radius = self:GetSpecialValueFor("radius")
	local vPos = self:GetCursorPosition()
	local flags = DOTA_DAMAGE_FLAG_DIRECT

    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        flags = flags + DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO
		hCaster:RemoveModifierByName("modifier_mage_fiery_soul_combo")
	end

	StopSoundOn("Hero_Invoker.SunStrike.Charge", hCaster)
	if self.particleID_pre ~= nil then
        ParticleManager:DestroyParticle(self.particleID_pre, true)
    end
	self.particleID_pre = nil
	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControl(particleID, 0, vPos)
	ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(particleID)

	EmitSoundOnLocationWithCaster(vPos, "Ability.LightStrikeArray", hCaster)
	
	local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), vPos, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if IsValid(enemy) and enemy:IsAlive() then
			ApplyDamage({
				victim = enemy,
				attacker = hCaster,
				damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self,
				damage_flags = flags,
			})
			if enemy:IsAlive() then
				enemy:AddNewModifier(hCaster, self, "modifier_mage_light_strike_array", {duration = duration})
			end
		end
	end

end
---------------------------------------------------------------------
--Modifiers
if modifier_mage_light_strike_array == nil then
	modifier_mage_light_strike_array = class({})
end
function modifier_mage_light_strike_array:OnCreated(params)
	self.slow_down_pct = self:GetAbilitySpecialValueFor("slow_down_pct")
	if IsServer() then
	end
end
function modifier_mage_light_strike_array:OnRefresh(params)
	self.slow_down_pct = self:GetAbilitySpecialValueFor("slow_down_pct")
	if IsServer() then
	end
end
function modifier_mage_light_strike_array:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_mage_light_strike_array:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow_down_pct
end