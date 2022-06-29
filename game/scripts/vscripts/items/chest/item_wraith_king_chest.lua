if  item_wraith_king_chest == nil then
    item_wraith_king_chest = class({})
end
LinkLuaModifier( "modifier_item_wraith_king_chest", "items/chest/item_wraith_king_chest.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function item_wraith_king_chest:GetIntrinsicModifierName()
    return "modifier_item_wraith_king_chest"
end
--modifier
if modifier_item_wraith_king_chest == nil then
	modifier_item_wraith_king_chest = class({})
end
function modifier_item_wraith_king_chest:IsHidden()
    return true
end
function modifier_item_wraith_king_chest:IsDebuff()
    return false
end 
function modifier_item_wraith_king_chest:IsPurgable()
    return false
end
function modifier_item_wraith_king_chest:CDeclareFunctions()
	return {
		CMODIFIER_PROPERTY_PHYSICAL_ARMOR_CONSTANT
	}
end
function modifier_item_wraith_king_chest:C_GetModifierPhysicalArmor_Constant()
	return self.bonus_armor
end
function modifier_item_wraith_king_chest:OnCreated(params)
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
end
function modifier_item_wraith_king_chest:OnRefresh(params)
    self.bonus_armor = self:GetAbilitySpecialValueFor("bonus_armor")
end
function modifier_item_wraith_king_chest:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end