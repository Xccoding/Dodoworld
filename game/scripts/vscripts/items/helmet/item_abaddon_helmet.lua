if  item_abaddon_helmet == nil then
    item_abaddon_helmet = class({})
end
LinkLuaModifier( "modifier_item_abaddon_helmet", "items/helmet/item_abaddon_helmet.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function item_abaddon_helmet:GetIntrinsicModifierName()
    return "modifier_item_abaddon_helmet"
end
--modifier
if modifier_item_abaddon_helmet == nil then
	modifier_item_abaddon_helmet = class({})
end
function modifier_item_abaddon_helmet:IsHidden()
    return true
end
function modifier_item_abaddon_helmet:IsDebuff()
    return false
end 
function modifier_item_abaddon_helmet:IsPurgable()
    return false
end
function modifier_item_abaddon_helmet:CDeclareFunctions()
	return {
		CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT,
	}
end
function modifier_item_abaddon_helmet:C_GetModifierPhysicalArmor_Constant()
	return self.bonus_armor
end
function modifier_item_abaddon_helmet:OnCreated(params)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_abaddon_helmet:OnRefresh(params)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_abaddon_helmet:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end