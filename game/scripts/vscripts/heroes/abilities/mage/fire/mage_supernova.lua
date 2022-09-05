if mage_supernova == nil then
    mage_supernova = class({})
end
LinkLuaModifier("modifier_mage_supernova", "heroes/abilities/mage/fire/mage_supernova.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_supernova_burn", "heroes/abilities/mage/fire/mage_supernova.lua", LUA_MODIFIER_MOTION_NONE)
--ability
function mage_supernova:GetIntrinsicModifierName()
    if self:GetLevel() >= 1 then
        return "modifier_mage_supernova"
    end
end
--超新星modifiers
if modifier_mage_supernova == nil then
    modifier_mage_supernova = class({})
end
function modifier_mage_supernova:IsHidden()
    return true
end
function modifier_mage_supernova:IsDebuff()
    return false
end
function modifier_mage_supernova:IsPurgable()
    return false
end
function modifier_mage_supernova:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end
function modifier_mage_supernova:CDeclareFunctions()
    return {
    }
end
function modifier_mage_supernova:CheckState()
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_mage_flame_cloak_buff") then
        return {
            [MODIFIER_STATE_UNSLOWABLE] = true
        }
    end
end
function modifier_mage_supernova:GetAbilityValues()
    self.reborn_health = self:GetAbilitySpecialValueFor("reborn_health")
    self.burn_health = self:GetAbilitySpecialValueFor("burn_health")
    self.bonus_movespeed = self:GetAbilitySpecialValueFor("bonus_movespeed")
end
function modifier_mage_supernova:OnCreated(params)
    self:GetAbilityValues()
    local hAbility = self:GetAbility()
    self.ConstantCooldown = KeyValues.AbilityKv[hAbility:GetAbilityName()].ConstantCooldown or 0
end
function modifier_mage_supernova:OnRefresh(params)
    self:GetAbilityValues()
    local hAbility = self:GetAbility()
    self.ConstantCooldown = KeyValues.AbilityKv[hAbility:GetAbilityName()].ConstantCooldown or 0
end
function modifier_mage_supernova:GetMinHealth()
    local hAbility = self:GetAbility()
    local hParent = self:GetParent()
    
    if hAbility:IsCooldownReady() and not hParent:HasModifier("modifier_forcekill_custom") then
        return 1
    end
end
function modifier_mage_supernova:OnTakeDamage(params)
    if IsServer() then
        local hParent = self:GetParent()
        local hAbility = self:GetAbility()
        if params.unit == hParent then
            if hParent:GetHealth() <= 1 and hAbility:IsCooldownReady() and not hParent:HasModifier("modifier_forcekill_custom") then
                hParent:SetHealth(hParent:GetMaxHealth() * self.reborn_health * 0.01)
                hParent:AddNewModifier(hParent, hAbility, "modifier_mage_supernova_burn", {duration = self.duration})

                local particleID = ParticleManager:CreateParticle("particles/units/heroes/mage/mage_supernova.vpcf", PATTACH_ABSORIGIN, hParent)
                ParticleManager:SetParticleControl(particleID, 0, hParent:GetAbsOrigin())
                ParticleManager:SetParticleControl(particleID, 300, hParent:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particleID)

                EmitSoundOn("Hero_Phoenix.SuperNova.Explode", hParent)

                hAbility:StartCooldown(self.ConstantCooldown)
            end
        end
    end
end
function modifier_mage_supernova:GetModifierMoveSpeedBonus_Percentage()
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_mage_flame_cloak_buff") then
        return self.bonus_movespeed
    end
end
--=======================================modifier_mage_supernova_burn=======================================
if modifier_mage_supernova_burn == nil then
    modifier_mage_supernova_burn = class({})
end
function modifier_mage_supernova_burn:IsHidden()
    return true
end
function modifier_mage_supernova_burn:IsDebuff()
    return false
end
function modifier_mage_supernova_burn:IsPurgable()
    return false
end
function modifier_mage_supernova_burn:IsPurgeException()
    return false
end
function modifier_mage_supernova_burn:OnCreated(params)
    self.burn_health = self:GetAbilitySpecialValueFor("burn_health")
    self.duration = self:GetAbilitySpecialValueFor("duration")
    self.burn_health_per_tick = self.burn_health / self.duration
    if IsServer() then
        local hParent = self:GetParent()
        self:StartIntervalThink(1)
        EmitSoundOn("Hero_Phoenix.SunRay.Loop", hParent)
    end
end
function modifier_mage_supernova_burn:OnRefresh(params)
end
function modifier_mage_supernova_burn:OnDestroy(params)
    if IsServer() then
        local hParent = self:GetParent()
        StopSoundOn("Hero_Phoenix.SunRay.Loop", hParent)
    end
end
function modifier_mage_supernova_burn:DeclareFunctions()
    return {
    }
end
function modifier_mage_supernova_burn:CDeclareFunctions()
    return {
    }
end
function modifier_mage_supernova_burn:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_sunray_debuff.vpcf"
end
function modifier_mage_supernova_burn:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_mage_supernova_burn:OnIntervalThink()
    local hParent = self:GetParent()
    local health_to_burn = hParent:GetMaxHealth() * self.burn_health_per_tick * 0.01

    if hParent:GetHealth() > health_to_burn + 1 then
        hParent:SetHealth(hParent:GetHealth() - health_to_burn + 1)
    else
        hParent:SetHealth(1)
    end
end
