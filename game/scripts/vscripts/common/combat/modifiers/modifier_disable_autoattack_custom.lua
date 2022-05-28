--modifiers
if modifier_disable_autoattack_custom == nil then
	modifier_disable_autoattack_custom = class({})
end
function modifier_disable_autoattack_custom:IsHidden()
    return true
end
function modifier_disable_autoattack_custom:IsDebuff()
    return true
end 
function modifier_disable_autoattack_custom:IsPurgable()
    return false
end
function modifier_disable_autoattack_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK
    }
end
function modifier_disable_autoattack_custom:GetDisableAutoAttack()
    return 1
end
