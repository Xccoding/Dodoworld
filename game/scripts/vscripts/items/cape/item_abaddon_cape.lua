if  item_abaddon_cape == nil then
    item_abaddon_cape = class({})
end
LinkLuaModifier( "modifier_item_abaddon_cape", "items/cape/item_abaddon_cape.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function item_abaddon_cape:GetIntrinsicModifierName()
    return "modifier_item_abaddon_cape"
end
--modifier
if modifier_item_abaddon_cape == nil then
	modifier_item_abaddon_cape = class({})
end
function modifier_item_abaddon_cape:IsHidden()
    return true
end
function modifier_item_abaddon_cape:IsDebuff()
    return false
end 
function modifier_item_abaddon_cape:IsPurgable()
    return false
end
function modifier_item_abaddon_cape:CDeclareFunctions()
	return {
		CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT
	}
end
function modifier_item_abaddon_cape:C_GetModifierPhysicalArmor_Constant()
	return self.bonus_armor
end
function modifier_item_abaddon_cape:OnCreated(params)
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
end
function modifier_item_abaddon_cape:OnRefresh(params)
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
end
function modifier_item_abaddon_cape:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end