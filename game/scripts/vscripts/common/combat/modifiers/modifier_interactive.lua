--=======================================modifier_interactive=======================================
if modifier_interactive == nil then
    modifier_interactive = class({})
end
function modifier_interactive:IsHidden()
    return true
end
function modifier_interactive:IsDebuff()
    return false
end
function modifier_interactive:IsPurgable()
    return false
end
function modifier_interactive:IsPurgeException()
    return false
end
function modifier_interactive:OnCreated(params)
end
function modifier_interactive:OnRefresh(params)
end
function modifier_interactive:OnDestroy(params)
end
function modifier_interactive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_AVOID_DAMAGE,
    }
end
function modifier_interactive:CDeclareFunctions()
    return {
    }
end
function modifier_interactive:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end
function modifier_interactive:CanParentBeAutoAttacked()
    return false
end
function modifier_interactive:GetModifierAvoidDamage()
    return 1
end
