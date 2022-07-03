--=======================================modifier_no_combat_slow=======================================
if modifier_no_combat_slow == nil then
    modifier_no_combat_slow = class({})
end
function modifier_no_combat_slow:IsHidden()
    return true
end
function modifier_no_combat_slow:IsDebuff()
    return false
end
function modifier_no_combat_slow:IsPurgable()
    return false
end
function modifier_no_combat_slow:IsPurgeException()
    return false
end
function modifier_no_combat_slow:OnCreated(params)
end
function modifier_no_combat_slow:OnRefresh(params)
end
function modifier_no_combat_slow:OnDestroy(params)
end
function modifier_no_combat_slow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_no_combat_slow:CDeclareFunctions()
    return {
    }
end
function modifier_no_combat_slow:GetModifierMoveSpeedBonus_Percentage()
    local hParent = self:GetParent()
    if not hParent:InCombat() and not hParent:HasModifier("modifier_escape") then
        return -40
    end
end