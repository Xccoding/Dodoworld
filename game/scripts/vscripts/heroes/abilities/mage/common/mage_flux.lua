LinkLuaModifier("modifier_mage_flux", "heroes/abilities/mage/common/mage_flux.lua", LUA_MODIFIER_MOTION_NONE)
--Abilities
if mage_flux == nil then
    mage_flux = class({})
end
function mage_flux:GetIntrinsicModifierName()
    if self:GetLevel() > 0 then
        return "modifier_mage_flux"
    end
end
--=======================================modifier_mage_flux=======================================
if modifier_mage_flux == nil then
    modifier_mage_flux = class({})
end
function modifier_mage_flux:IsHidden()
    return false
end
function modifier_mage_flux:IsDebuff()
    return false
end
function modifier_mage_flux:IsPurgable()
    return false
end
function modifier_mage_flux:IsPurgeException()
    return false
end
function modifier_mage_flux:GetAbilityValues()
    self.bonus_dmg_pct_min = self:GetAbilitySpecialValueFor("bonus_dmg_pct_min")
    self.bonus_dmg_pct_max = self:GetAbilitySpecialValueFor("bonus_dmg_pct_max")
    self.stack_ps = self:GetAbilitySpecialValueFor("stack_ps")
end
function modifier_mage_flux:OnCreated(params)
    self:GetAbilityValues()
    if IsServer() then
        self:StartIntervalThink(1)
		self:SetStackCount(self.bonus_dmg_pct_min)
    end
end
function modifier_mage_flux:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_flux:OnDestroy(params)
end
function modifier_mage_flux:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end
function modifier_mage_flux:CDeclareFunctions()
    return {
    }
end
function modifier_mage_flux:OnIntervalThink()
    if self:GetStackCount() < self.bonus_dmg_pct_max then
        self:SetStackCount(self:GetStackCount() + self.stack_ps)
    else
        self:SetStackCount(self.bonus_dmg_pct_min)
    end
end
function modifier_mage_flux:GetModifierTotalDamageOutgoing_Percentage(params)
    if params.damage_type == DAMAGE_TYPE_MAGICAL then
        return self:GetStackCount()
    end
end
function modifier_mage_flux:OnTooltip()
    return self:GetStackCount()
end