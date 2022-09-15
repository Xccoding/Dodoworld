LinkLuaModifier("modifier_mage_flame_cloak_buff", "heroes/abilities/mage/fire/mage_flame_cloak.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_flame_cloak", "heroes/abilities/mage/fire/mage_flame_cloak.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if mage_flame_cloak == nil then
    mage_flame_cloak = class({})
end
function mage_flame_cloak:OnSpellStart()
    local hCaster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    hCaster:AddNewModifier(hCaster, self, "modifier_mage_flame_cloak_buff", { duration = duration })
    EmitSoundOn("Hero_Lina.FlameCloak.Cast", hCaster)
end
function mage_flame_cloak:GetIntrinsicModifierName()
    return "modifier_mage_flame_cloak"
end
---------------------------------------------------------------------
--燃烧Modifiers
if modifier_mage_flame_cloak_buff == nil then
    modifier_mage_flame_cloak_buff = class({})
end
function modifier_mage_flame_cloak_buff:IsDebuff()
    return false
end
function modifier_mage_flame_cloak_buff:IsHidden()
    return false
end
function modifier_mage_flame_cloak_buff:IsPurgable()
    return false
end
function modifier_mage_flame_cloak_buff:GetAbilityValues()
    self.bonus_magical_crit_chance = self:GetAbilitySpecialValueFor("bonus_magical_crit_chance")
end
function modifier_mage_flame_cloak_buff:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        local hCaster = self:GetCaster()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_flame_cloak.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
        ParticleManager:SetParticleControlEnt(particleID, 0, hCaster, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
        ParticleManager:SetParticleControlEnt(particleID, 1, hCaster, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 0), false)
        self:AddParticle(particleID, false, false, -1, false, false)
    end
end
function modifier_mage_flame_cloak_buff:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_flame_cloak_buff:GetStatusEffectName()
    return "particles/status_fx/status_effect_lina_flame_cloak.vpcf"
end
function modifier_mage_flame_cloak_buff:StatusEffectPriority()
    return 3
end
function modifier_mage_flame_cloak_buff:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT,
    }
end
function modifier_mage_flame_cloak_buff:C_GetModifierBonusMagicalCritChance_Percent(params)
    return self.bonus_magical_crit_chance
end
--=======================================modifier_mage_flame_cloak=======================================
if modifier_mage_flame_cloak == nil then
    modifier_mage_flame_cloak = class({})
end
function modifier_mage_flame_cloak:IsHidden()
    return true
end
function modifier_mage_flame_cloak:IsDebuff()
    return false
end
function modifier_mage_flame_cloak:IsPurgable()
    return false
end
function modifier_mage_flame_cloak:IsPurgeException()
    return false
end
function modifier_mage_flame_cloak:GetAbilityValues()
    self.flowing_blaze_cd_reduce = self:GetAbilitySpecialValueFor("flowing_blaze_cd_reduce")
end
function modifier_mage_flame_cloak:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_flame_cloak:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_flame_cloak:OnDestroy(params)
end
function modifier_mage_flame_cloak:DeclareFunctions()
    return {
    }
end
function modifier_mage_flame_cloak:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_SPELL_CRIT,
    }
end
function modifier_mage_flame_cloak:C_OnSpellCrit(params)
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()
    local hAbility = self:GetAbility()
    if params.attacker == hCaster and self.flowing_blaze_cd_reduce > 0 then
        if params.inflictor and (params.inflictor:GetAbilityName() == "mage_searing_arrows" or params.inflictor:GetAbilityName() == "mage_laguna_blade" or params.inflictor:GetAbilityName() == "mage_dragon_slave" or params.inflictor:GetAbilityName() == "mage_fireblast") then
            local origin_cd = hAbility:GetCooldownTimeRemaining()
            hAbility:EndCooldown()
            hAbility:StartCooldown(math.max(0, origin_cd - self.flowing_blaze_cd_reduce))
        end
    end
end