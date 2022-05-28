if  item_abaddon_shoulder == nil then
    item_abaddon_shoulder = class({})
end
LinkLuaModifier( "modifier_item_abaddon_shoulder", "items/shoulder/item_abaddon_shoulder.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function item_abaddon_shoulder:GetIntrinsicModifierName()
    return "modifier_item_abaddon_shoulder"
end
--modifier
if modifier_item_abaddon_shoulder == nil then
	modifier_item_abaddon_shoulder = class({})
end
function modifier_item_abaddon_shoulder:IsHidden()
    return true
end
function modifier_item_abaddon_shoulder:IsDebuff()
    return false
end 
function modifier_item_abaddon_shoulder:IsPurgable()
    return false
end
function modifier_item_abaddon_shoulder:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_item_abaddon_shoulder:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end
function modifier_item_abaddon_shoulder:OnCreated(params)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_abaddon_shoulder:OnRefresh(params)
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end
function modifier_item_abaddon_shoulder:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end