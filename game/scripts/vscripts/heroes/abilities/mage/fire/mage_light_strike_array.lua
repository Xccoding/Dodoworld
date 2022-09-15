LinkLuaModifier("modifier_mage_light_strike_array", "heroes/abilities/mage/fire/mage_light_strike_array.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_light_strike_array_fire_land", "heroes/abilities/mage/fire/mage_light_strike_array.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if mage_light_strike_array == nil then
    mage_light_strike_array = class({})
end
function mage_light_strike_array:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
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
        return "mage/mage_light_strike_array"
    else
        return "lina_light_strike_array"
    end
end
function mage_light_strike_array:C_OnAbilityPhaseStart()
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
function mage_light_strike_array:C_OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()
    StopSoundOn("Hero_Invoker.SunStrike.Charge", hCaster)
    ParticleManager:DestroyParticle(self.particleID_pre, true)
    self.particleID_pre = nil
    return true
end
function mage_light_strike_array:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local radius = self:GetSpecialValueFor("radius")
    local fire_land_duration = self:GetSpecialValueFor("fire_land_duration")
    local vPos = self:GetCursorPosition()
    local flags = DOTA_DAMAGE_FLAG_DIRECT

    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        flags = flags + DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO
        hCaster:RemoveModifierByName("modifier_mage_fiery_soul_combo")
        self:EndCooldown()
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
                enemy:AddNewModifier(hCaster, self, "modifier_mage_light_strike_array", { duration = duration })
            end
        end
    end

    if fire_land_duration > 0 then
        CreateModifierThinker(hCaster, self, "modifier_mage_light_strike_array_fire_land", { duration = fire_land_duration }, vPos, hCaster:GetTeamNumber(), false)
    end

end
---------------------------------------------------------------------
--Modifiers
if modifier_mage_light_strike_array == nil then
    modifier_mage_light_strike_array = class({})
end
function modifier_mage_light_strike_array:GetAbilityValues()
    self.slow_down_pct = self:GetAbilitySpecialValueFor("slow_down_pct")
end
function modifier_mage_light_strike_array:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_light_strike_array:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_light_strike_array:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_mage_light_strike_array:GetModifierMoveSpeedBonus_Percentage()
    return -self.slow_down_pct
end
--=======================================modifier_mage_light_strike_array_fire_land=======================================
if modifier_mage_light_strike_array_fire_land == nil then
    modifier_mage_light_strike_array_fire_land = class({})
end
function modifier_mage_light_strike_array_fire_land:IsHidden()
    return true
end
function modifier_mage_light_strike_array_fire_land:IsDebuff()
    return false
end
function modifier_mage_light_strike_array_fire_land:IsPurgable()
    return false
end
function modifier_mage_light_strike_array_fire_land:IsPurgeException()
    return false
end
function modifier_mage_light_strike_array_fire_land:GetAbilityValues()
    self.fire_land_sp_factor = self:GetAbilitySpecialValueFor("fire_land_sp_factor")
    self.radius = self:GetAbilitySpecialValueFor("radius")
end
function modifier_mage_light_strike_array_fire_land:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        local hCaster = self:GetCaster()
        local hParent = self:GetParent()

        self:StartIntervalThink(1)
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/mage/mage_fire_land.vpcf", PATTACH_CUSTOMORIGIN, hParent)
        ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
        ParticleManager:SetParticleControl(particleID, 1, Vector(self:GetDuration(), 0, 0))
        ParticleManager:ReleaseParticleIndex(particleID)
    end
end
function modifier_mage_light_strike_array_fire_land:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_light_strike_array_fire_land:OnDestroy(params)
end
function modifier_mage_light_strike_array_fire_land:DeclareFunctions()
    return {
    }
end
function modifier_mage_light_strike_array_fire_land:CDeclareFunctions()
    return {
    }
end
function modifier_mage_light_strike_array_fire_land:OnIntervalThink()
    local hCaster = self:GetCaster()
    local hAbility = self:GetAbility()
    local hParent = self:GetParent()

    local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hParent:GetAbsOrigin(), nil, self.radius, hAbility:GetAbilityTargetTeam(), hAbility:GetAbilityTargetType(), hAbility:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        if IsValid(enemy) and enemy:IsAlive() then
            ApplyDamage({
                victim = enemy,
                attacker = hCaster,
                damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * self.fire_land_sp_factor * 0.01,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = hAbility,
                damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
            })
        end
    end
end