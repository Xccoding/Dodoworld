if mage_fire_spirits == nil then
    mage_fire_spirits = class({})
end
LinkLuaModifier("modifier_mage_fire_spirits", "heroes/abilities/mage/fire/mage_fire_spirits.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mage_fire_spirits_movespeed", "heroes/abilities/mage/fire/mage_fire_spirits.lua", LUA_MODIFIER_MOTION_NONE)
--ability
function mage_fire_spirits:GetManaCost(iLevel)
    local hCaster = self:GetCaster()
    return self:GetSpecialValueFor("mana_cost_pct") * hCaster:GetMaxMana() * 0.01
end
function mage_fire_spirits:GetIntrinsicModifierName()
    return "modifier_mage_fire_spirits"
end
function mage_fire_spirits:C_OnSpellStart()
    local hCaster = self:GetCaster()
    local spell_time = Abilities_manager:GetAbilityValue(self, "MovingCastTime")
    self.hTarget = self:GetCursorTarget()

    -- local keys = {
    --     "sp_factor",
    --     "spell_time",
    -- }

    hCaster:AddNewModifier(hCaster, self, "modifier_hero_movingcast", {
        Callback = "Fire",
        duration = spell_time,
    -- Keys = TabletoString(keys),
    })

    EmitSoundOn("Hero_Phoenix.FireSpirits.Cast", hCaster)
end
function mage_fire_spirits:Fire()
    local hCaster = self:GetCaster()
    local speed = self:GetSpecialValueFor("speed")
    local bonus_movespeed_duration = self:GetSpecialValueFor("bonus_movespeed_duration")

    local info = {
        Target = self.hTarget,
        Source = hCaster,
        Ability = self,
        EffectName = "particles/units/heroes/mage/mage_fire_spirits.vpcf",
        iMoveSpeed = speed,
        bDodgeable = true,        
        vSourceLoc = hCaster:GetAbsOrigin(),
        bIsAttack = false,                
        ExtraData = {},
    }

    ProjectileManager:CreateTrackingProjectile(info)

    EmitSoundOn("Hero_Phoenix.FireSpirits.Launch", hCaster)

    if bonus_movespeed_duration > 0 then
        hCaster:AddNewModifier(hCaster, self, "mage_fire_spirits_movespeed", {duration = bonus_movespeed_duration})
    end

end
function mage_fire_spirits:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if IsValid(hTarget) then
        local hCaster = self:GetCaster()
        local sp_factor = self:GetSpecialValueFor("sp_factor")

        EmitSoundOn("Hero_Phoenix.ProjectileImpact", hCaster)

        ApplyDamage({
            victim = hTarget,
            attacker = hCaster,
            damage = hCaster:GetDamageforAbility(ABILITY_DAMAGE_CALCULATE_TYPE_SP) * sp_factor * 0.01,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_DIRECT,
        })
    end
end
--=======================================modifier_mage_fire_spirits=======================================
if modifier_mage_fire_spirits == nil then
    modifier_mage_fire_spirits = class({})
end
function modifier_mage_fire_spirits:IsHidden()
    return true
end
function modifier_mage_fire_spirits:IsDebuff()
    return false
end
function modifier_mage_fire_spirits:IsPurgable()
    return false
end
function modifier_mage_fire_spirits:IsPurgeException()
    return false
end
function modifier_mage_fire_spirits:GetAbilityValues()
    self.bonus_dmg_hp_pct = self:GetAbilitySpecialValueFor("bonus_dmg_hp_pct")
    self.lowhp_bonus_dmg_pct = self:GetAbilitySpecialValueFor("lowhp_bonus_dmg_pct")
end
function modifier_mage_fire_spirits:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_fire_spirits:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_fire_spirits:OnDestroy(params)
end
function modifier_mage_fire_spirits:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function modifier_mage_fire_spirits:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_CONSTANT
    }
end
function modifier_mage_fire_spirits:C_GetModifierBonusMagicalCritChance_Constant(params)
    if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
        local hTarget = params.target
        if self.bonus_dmg_hp_pct > 0 and hTarget:GetHealthPercent() < self.bonus_dmg_hp_pct then
            return 100
        end
    end
    return 0
end
function modifier_mage_fire_spirits:GetModifierTotalDamageOutgoing_Percentage(params)
    if IsServer() then
        if params.inflictor ~= nil and params.inflictor == self:GetAbility() then
            local hTarget = params.target
            if self.bonus_dmg_hp_pct > 0 and hTarget:GetHealthPercent() < self.bonus_dmg_hp_pct then
                return self.lowhp_bonus_dmg_pct
            end
        end
    end
end
--=======================================mage_fire_spirits_movespeed=======================================
if mage_fire_spirits_movespeed == nil then
    mage_fire_spirits_movespeed = class({})
end
function mage_fire_spirits_movespeed:IsHidden()
    return true
end
function mage_fire_spirits_movespeed:IsDebuff()
    return false
end
function mage_fire_spirits_movespeed:IsPurgable()
    return false
end
function mage_fire_spirits_movespeed:IsPurgeException()
    return false
end
function mage_fire_spirits_movespeed:GetAbilityValues()
    self.bonus_movespeed_pct = self:GetAbilitySpecialValueFor("bonus_movespeed_pct")
end
function mage_fire_spirits_movespeed:OnCreated(params)
    self:GetAbilityValues()
end
function mage_fire_spirits_movespeed:OnRefresh(params)
    self:GetAbilityValues()
end
function mage_fire_spirits_movespeed:OnDestroy(params)
end
function mage_fire_spirits_movespeed:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function mage_fire_spirits_movespeed:CDeclareFunctions()
    return {
    }
end
function mage_fire_spirits_movespeed:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_movespeed_pct
end