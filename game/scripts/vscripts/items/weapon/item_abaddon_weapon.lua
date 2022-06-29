if  item_abaddon_weapon == nil then
    item_abaddon_weapon = class({})
end
LinkLuaModifier( "modifier_item_abaddon_weapon", "items/weapon/item_abaddon_weapon.lua", LUA_MODIFIER_MOTION_NONE )
--ability
function item_abaddon_weapon:GetIntrinsicModifierName()
    return "modifier_item_abaddon_weapon"
end
--modifier
if modifier_item_abaddon_weapon == nil then
	modifier_item_abaddon_weapon = class({})
end
function modifier_item_abaddon_weapon:IsHidden()
    return true
end
function modifier_item_abaddon_weapon:IsDebuff()
    return false
end 
function modifier_item_abaddon_weapon:IsPurgable()
    return false
end
function modifier_item_abaddon_weapon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS_UNIQUE,
	}
end
function modifier_item_abaddon_weapon:CDeclareFunctions()
    return {
        CMODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }
end
function modifier_item_abaddon_weapon:C_GetModifierBaseAttackTime_Constant()
    return self.attack_time
end
function modifier_item_abaddon_weapon:GetModifierPreAttack_BonusDamage()
	return self.bonus_attack
end
function modifier_item_abaddon_weapon:GetModifierAttackRangeBonusUnique()
    return self.bonus_attack_range
end
function modifier_item_abaddon_weapon:OnCreated(params)
    self.bonus_attack = self:GetAbilitySpecialValueFor("bonus_attack")
    self.attack_time = self:GetAbilitySpecialValueFor("attack_time")
    self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
end
function modifier_item_abaddon_weapon:OnRefresh(params)
    self.bonus_attack = self:GetAbilitySpecialValueFor("bonus_attack")
    self.attack_time = self:GetAbilitySpecialValueFor("attack_time")
    self.bonus_attack_range = self:GetAbilitySpecialValueFor("bonus_attack_range")
end
function modifier_item_abaddon_weapon:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end