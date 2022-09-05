if  mage_deflagration == nil then
    mage_deflagration = class({})
end
LinkLuaModifier( "modifier_mage_deflagration", "heroes/abilities/mage/fire/mage_deflagration.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function mage_deflagration:GetIntrinsicModifierName()
    if self:GetLevel() >= 1 then
        return "modifier_mage_deflagration"
    end
end
--爆燃modifiers
if modifier_mage_deflagration == nil then
	modifier_mage_deflagration = class({})
end
function modifier_mage_deflagration:IsHidden()
    return true
end
function modifier_mage_deflagration:IsDebuff()
    return false
end 
function modifier_mage_deflagration:IsPurgable()
    return false
end
function modifier_mage_deflagration:DeclareFunctions()
    return {
    }
end
function modifier_mage_deflagration:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_PERCENT,
        CMODIFIER_PROPERTY_BONUS_MAGICAL_CRIT_CHANCE_TOTAL_PERCENT
    }
end
function modifier_mage_deflagration:GetAbilityValues()
    self.bonus_crit = self:GetAbilitySpecialValueFor("bonus_crit")
    self.total_crit = self:GetAbilitySpecialValueFor("total_crit")
end
function modifier_mage_deflagration:OnCreated(params)
    self:GetAbilityValues()
end
function modifier_mage_deflagration:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_deflagration:C_GetModifierBonusMagicalCritChance_Percent( params )
    return self.bonus_crit
end
function modifier_mage_deflagration:C_GetModifierBonusMagicalCritChance_Total_Percent( params )
    return self.total_crit
end

