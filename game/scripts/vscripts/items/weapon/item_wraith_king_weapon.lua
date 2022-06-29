if  item_wraith_king_weapon == nil then
    item_wraith_king_weapon = class({})
end
LinkLuaModifier( "modifier_item_wraith_king_weapon", "items/weapon/item_wraith_king_weapon.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function item_wraith_king_weapon:GetIntrinsicModifierName()
    return "modifier_item_wraith_king_weapon"
end
--modifier
if modifier_item_wraith_king_weapon == nil then
	modifier_item_wraith_king_weapon = class({})
end
function modifier_item_wraith_king_weapon:IsHidden()
    return true
end
function modifier_item_wraith_king_weapon:IsDebuff()
    return false
end 
function modifier_item_wraith_king_weapon:IsPurgable()
    return false
end
function modifier_item_wraith_king_weapon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
	}
end
function modifier_item_wraith_king_weapon:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }
end
function modifier_item_wraith_king_weapon:C_GetModifierBaseAttackTime_Constant()
    return self.attack_time
end
function modifier_item_wraith_king_weapon:GetModifierPreAttack_BonusDamage()
	return self.bonus_attack
end
function modifier_item_wraith_king_weapon:GetModifierAttackRangeBonusUnique()
    return self.bonus_attack_range
end
function modifier_item_wraith_king_weapon:OnCreated(params)
    self.bonus_attack = self:GetAbilitySpecialValueFor("bonus_attack")
    self.attack_time = self:GetAbilitySpecialValueFor("attack_time")
    self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
end
function modifier_item_wraith_king_weapon:OnRefresh(params)
    self.bonus_attack = self:GetAbilitySpecialValueFor("bonus_attack")
    self.attack_time = self:GetAbilitySpecialValueFor("attack_time")
    self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
end
function modifier_item_wraith_king_weapon:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end