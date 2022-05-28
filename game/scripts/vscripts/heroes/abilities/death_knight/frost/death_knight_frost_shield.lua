LinkLuaModifier( "modifier_death_knight_frost_shield", "heroes/abilities/death_knight/frost/death_knight_frost_shield.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_death_knight_frost_shield_slow_down", "heroes/abilities/death_knight/frost/death_knight_frost_shield.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if death_knight_frost_shield == nil then
	death_knight_frost_shield = class({})
end
function death_knight_frost_shield:OnSpellStart()
	local hCaster = self:GetCaster()
	local hAbility = self
	local duration = self:GetSpecialValueFor("duration")
	local mana_get_pct = self:GetSpecialValueFor("mana_get_pct")

	hCaster:AddNewModifier(hCaster, hAbility, "modifier_death_knight_frost_shield", {duration = duration})

	hCaster:CGiveMana(hCaster:GetMaxMana() * mana_get_pct * 0.01, self, hCaster)

	EmitSoundOn("Hero_Lich.IceAge", hCaster)
end
---------------------------------------------------------------------
--冰盾Modifiers
if modifier_death_knight_frost_shield == nil then
	modifier_death_knight_frost_shield = class({})
end
function modifier_death_knight_frost_shield:OnCreated(params)
    self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
    self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.debuff_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
	self.bonus_armor_pct = self:GetAbility():GetSpecialValueFor("bonus_armor_pct")

	local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(particleID, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "", self:GetCaster():GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(particleID, 2, Vector(self.radius, self.radius, self.radius))
	self:AddParticle(particleID, false, false, -1, false, false)

	if IsServer() then
		self:StartIntervalThink(self.dot_interval)
		self:OnIntervalThink()
	end
end
function modifier_death_knight_frost_shield:OnRefresh(params)
    self.ap_factor = self:GetAbility():GetSpecialValueFor("ap_factor")
    self.dot_interval = self:GetAbility():GetSpecialValueFor("dot_interval")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.debuff_duration = self:GetAbility():GetSpecialValueFor("debuff_duration")
	self.bonus_armor_pct = self:GetAbility():GetSpecialValueFor("bonus_armor_pct")
	if IsServer() then
		self:OnIntervalThink()
	end
end
function modifier_death_knight_frost_shield:OnIntervalThink()
	if IsServer() then
        local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()

		EmitSoundOn("Hero_Lich.IceAge.Tick", hCaster)

		local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_ice_age_dmg.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
		ParticleManager:SetParticleControlEnt(particleID, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "", self:GetCaster():GetAbsOrigin(), false)
		ParticleManager:SetParticleControl(particleID, 2, Vector(self.radius, self.radius, self.radius))
		ParticleManager:ReleaseParticleIndex(particleID)
        
		local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hCaster:GetAbsOrigin(), nil, self.radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if enemy ~= nil and enemy:IsAlive()then
                ApplyDamage({
                    victim = enemy,
                    attacker = hCaster,
                    damage = hCaster:GetDamageforAbility(true) * self.ap_factor * 0.01,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = hAbility,
                    damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
                })

				EmitSoundOn("Hero_Lich.IceAge.Damage", enemy)

                enemy:AddNewModifier(hCaster, hAbility, "modifier_death_knight_frost_shield_slow_down", {duration = self.debuff_duration})
            end
        end

    end
end
function modifier_death_knight_frost_shield:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_TOTAL_PERCENTAGE,
	}
end
function modifier_death_knight_frost_shield:GetModifierPhysicalArmorTotal_Percentage()
	return self.bonus_armor_pct
end
--减速Modifiers
if modifier_death_knight_frost_shield_slow_down == nil then
	modifier_death_knight_frost_shield_slow_down = class({})
end
function modifier_death_knight_frost_shield_slow_down:OnCreated(params)
	self.slow_down_pct = self:GetAbility():GetSpecialValueFor("slow_down_pct")
	if IsServer() then
		local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_lich/lich_ice_age_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:ReleaseParticleIndex(particleID)
	end
end
function modifier_death_knight_frost_shield_slow_down:OnRefresh(params)
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	if IsServer() then
		local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_lich/lich_ice_age_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:ReleaseParticleIndex(particleID)
	end
end
function modifier_death_knight_frost_shield_slow_down:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_death_knight_frost_shield_slow_down:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow_down_pct
end
function modifier_death_knight_frost_shield_slow_down:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end
function modifier_death_knight_frost_shield_slow_down:StatusEffectPriority()
	return 1
end