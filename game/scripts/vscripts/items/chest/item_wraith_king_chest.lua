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
function modifier_item_wraith_king_chest:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_item_wraith_king_chest:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end
function modifier_item_wraith_king_chest:OnCreated(params)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_wraith_king_chest:OnRefresh(params)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_wraith_king_chest:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end