LinkLuaModifier("modifier_mage_laguna_blade", "heroes/abilities/mage/fire/mage_laguna_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_laguna_blade_debuff", "heroes/abilities/mage/fire/mage_laguna_blade.lua", LUA_MODIFIER_MOTION_NONE)

if mage_laguna_blade == nil then
    mage_laguna_blade = class({})
end
--ability
function mage_laguna_blade:GetCastAnimation()
    local hCaster = self:GetCaster()
    if hCaster:GetUnitName() == "npc_dota_hero_lina" then
        return ACT_DOTA_CAST_ABILITY_4
    elseif hCaster:GetUnitName() == "npc_dota_hero_silencer" then
        return ACT_DOTA_CAST_ABILITY_3
    end
end
function mage_laguna_blade:GetCastPoint()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return 0
    end
    return tonumber(tostring(self.BaseClass.GetCastPoint(self)))
end
function mage_laguna_blade:GetPlaybackRateOverride()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return 1000
    end
    return tonumber(tostring(self.BaseClass.GetPlaybackRateOverride(self)))
end
function mage_laguna_blade:GetAbilityTextureName()
    local hCaster = self:GetCaster()
    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        return "mage_laguna_blade"
    else
        return "lina_laguna_blade"
    end
end
function mage_laguna_blade:C_OnAbilityPhaseStart()
    local hCaster = self:GetCaster()

    if not hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        EmitSoundOnEntityForPlayer("Hero_StormSpirit.ElectricVortex", hCaster, hCaster:GetPlayerOwnerID())
    end
    self.particleID_pre = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
    ParticleManager:SetParticleControlEnt(self.particleID_pre, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(self.particleID_pre, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0, 0, 0), false)
end
function mage_laguna_blade:C_OnAbilityPhaseInterrupted()
    local hCaster = self:GetCaster()
    StopSoundOn("Hero_StormSpirit.ElectricVortex", hCaster)
    ParticleManager:DestroyParticle(self.particleID_pre, true)
    self.particleID_pre = nil
end
function mage_laguna_blade:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local sp_factor = self:GetSpecialValueFor("sp_factor")
    local flags = DOTA_DAMAGE_FLAG_DIRECT

    if hCaster:HasModifier("modifier_mage_fiery_soul_combo") then
        flags = flags + DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO
        hCaster:RemoveModifierByName("modifier_mage_fiery_soul_combo")
    end

    StopSoundOn("Hero_StormSpirit.ElectricVortex", hCaster)
    if self.particleID_pre ~= nil then
        ParticleManager:DestroyParticle(self.particleID_pre, true)
    end
    self.particleID_pre = nil
    local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_ABSORIGIN, hTarget)
    ParticleManager:SetParticleControlEnt(iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0, 0, 0), false)
    ParticleManager:SetParticleControlEnt(iParticleID, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), false)
    ParticleManager:ReleaseParticleIndex(iParticleID)

    EmitSoundOn("Ability.LagunaBlade", hCaster)
    EmitSoundOn("Ability.LagunaBladeImpact", hTarget)

    ApplyDamage(
    {
        victim = hTarget,
        attacker = hCaster,
        damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
        damage_flags = flags,
    }
    )

    if self:GetLevel() >= 2 and hTarget:IsAlive() then
        hTarget:AddNewModifier(hCaster, self, "modifier_mage_laguna_blade_debuff", { duration = self:GetSpecialValueFor("duration") })
    end
end
function mage_laguna_blade:GetIntrinsicModifierName()
    return "modifier_mage_laguna_blade"
end
--=======================================modifier_mage_laguna_blade_debuff=======================================
if modifier_mage_laguna_blade_debuff == nil then
    modifier_mage_laguna_blade_debuff = class({})
end
function modifier_mage_laguna_blade_debuff:IsHidden()
    return false
end
function modifier_mage_laguna_blade_debuff:IsDebuff()
    return true
end
function modifier_mage_laguna_blade_debuff:IsPurgable()
    return true
end
function modifier_mage_laguna_blade_debuff:IsPurgeException()
    return true
end
function modifier_mage_laguna_blade_debuff:GetAbilityValues()
    self.sp_factor_dot = self:GetAbilitySpecialValueFor("sp_factor_dot")
end
function modifier_mage_laguna_blade_debuff:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        self:StartIntervalThink(1)
        self:OnIntervalThink()
    end
end
function modifier_mage_laguna_blade_debuff:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_laguna_blade_debuff:OnDestroy(params)
end
function modifier_mage_laguna_blade_debuff:DeclareFunctions()
    return {
    }
end
function modifier_mage_laguna_blade_debuff:CDeclareFunctions()
    return {
    }
end
function modifier_mage_laguna_blade_debuff:OnIntervalThink()
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()

    local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, hParent)
    -- ParticleManager:SetParticleControl(particleID, 0, Vector(0, 0, 0))
    ParticleManager:ReleaseParticleIndex(particleID)

    ApplyDamage(
    {
        victim = hParent,
        attacker = hCaster,
        damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * self.sp_factor_dot * 0.01,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
        damage_flags = DOTA_DAMAGE_FLAG_INDIRECT,
    })
end
--=======================================mage_laguna_blade=======================================
if modifier_mage_laguna_blade == nil then
    modifier_mage_laguna_blade = class({})
end
function modifier_mage_laguna_blade:IsHidden()
    return true
end
function modifier_mage_laguna_blade:IsDebuff()
    return false
end
function modifier_mage_laguna_blade:IsPurgable()
    return false
end
function modifier_mage_laguna_blade:IsPurgeException()
    return false
end
function modifier_mage_laguna_blade:GetAbilityValues()
    self.crit_hp_pct = self:GetAbilitySpecialValueFor("crit_hp_pct")
end
function modifier_mage_laguna_blade:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_laguna_blade:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_laguna_blade:OnDestroy(params)
end
function modifier_mage_laguna_blade:DeclareFunctions()
    return {
    }
end
function modifier_mage_laguna_blade:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT
    }
end
function modifier_mage_laguna_blade:C_GetModifierBonusMagicalCritChance_Constant(params)
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
        if self.crit_hp_pct > 0 and params.target:GetHealthPercent() > self.crit_hp_pct then
            return 100
        end
        return 0
    else
        return 0
    end
end