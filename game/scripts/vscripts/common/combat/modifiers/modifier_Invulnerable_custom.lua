--=======================================modifier_Invulnerable_custom=======================================
if modifier_Invulnerable_custom == nil then
    modifier_Invulnerable_custom = class({})
end
function modifier_Invulnerable_custom:IsHidden()
    return true
end
function modifier_Invulnerable_custom:IsDebuff()
    return false
end
function modifier_Invulnerable_custom:IsPurgable()
    return false
end
function modifier_Invulnerable_custom:IsPurgeException()
    return false
end
function modifier_Invulnerable_custom:OnCreated(params)
end
function modifier_Invulnerable_custom:OnRefresh(params)
end
function modifier_Invulnerable_custom:OnDestroy(params)
end
function modifier_Invulnerable_custom:DeclareFunctions()
    return {
    }
end
function modifier_Invulnerable_custom:CDeclareFunctions()
    return {
    }
end
function modifier_Invulnerable_custom:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end