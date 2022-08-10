--普通单位属性modifiers
if modifier_basic_attribute == nil then
	modifier_basic_attribute = class({})
end
function modifier_basic_attribute:IsHidden()
    return false
end
function modifier_basic_attribute:IsDebuff()
    return false
end 
function modifier_basic_attribute:IsPurgable()
    return false
end
function modifier_basic_attribute:RemoveOnDeath()
    return false
end
function modifier_basic_attribute:OnCreated( kv )
    if IsServer() then
        self.ArmorPhysical = kv.ArmorPhysical
        self.CustomMagicalResistance = kv.CustomMagicalResistance
    end
end
function modifier_basic_attribute:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT,
        CMODIFIER_PROPERTY_MAGICAL_ARMOR_CONSTANT,
    }
end
function modifier_basic_attribute:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end
--魔法恢复
function modifier_basic_attribute:GetModifierConstantManaRegen()
    local unit = self:GetParent()

    if not unit:IsUseMana() then
        return -self:GetParent():GetIntellect() * 0.05
    else
        return -self:GetParent():GetIntellect() * 0.05 + self:GetParent():GetIntellect() * CDOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN
    end
end

--魔法护甲
function modifier_basic_attribute:C_GetModifierMagicalArmor_Constant( params )
    local hParent = self:GetParent()
    return KeyValues:GetUnitSpecialValue(hParent, "CustomMagicalResistance") * 100
end
--护甲
function modifier_basic_attribute:C_GetModifierPhysicalArmor_Constant( params )
    local hParent = self:GetParent()
    return KeyValues:GetUnitSpecialValue(hParent, "ArmorPhysical") * 100
end
--战斗外生命恢复
function modifier_basic_attribute:GetModifierHealthRegenPercentage()
    local hParent = self:GetParent()
    if hParent:InCombat() then
        return 0
    end
    return CDOTA_ATTRIBUTE_HEALTH_REGEN_NO_COMBAT
end
