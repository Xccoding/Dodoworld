--=======================================modifier_Invulnerable=======================================
if modifier_Invulnerable == nil then
    modifier_Invulnerable = class({})
end
function modifier_Invulnerable:IsHidden()
    return true
end
function modifier_Invulnerable:IsDebuff()
    return false
end
function modifier_Invulnerable:IsPurgable()
    return false
end
function modifier_Invulnerable:IsPurgeException()
    return false
end
function modifier_Invulnerable:OnCreated(params)
end
function modifier_Invulnerable:OnRefresh(params)
end
function modifier_Invulnerable:OnDestroy(params)
end
function modifier_Invulnerable:DeclareFunctions()
    return {
    }
end
function modifier_Invulnerable:CDeclareFunctions()
    return {
    }
end
function modifier_Invulnerable:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
end