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
    if IsServer() then
        self:SetHasCustomTransmitterData(true)
        self.slow_down = params.slow_down
    end
end
function modifier_no_combat_slow:OnRefresh(params)
end
function modifier_no_combat_slow:OnDestroy(params)
end
function modifier_no_combat_slow:AddCustomTransmitterData()
    return {
        slow_down = self.slow_down
    }
end
function modifier_no_combat_slow:HandleCustomTransmitterData( params )
    self.slow_down = params.slow_down
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
        return -self.slow_down
    end
end