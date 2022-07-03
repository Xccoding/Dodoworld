--标记怪物逃跑用modifiers
--=======================================modifier_escape=======================================
if modifier_escape == nil then
    modifier_escape = class({})
end
function modifier_escape:IsHidden()
    return true
end
function modifier_escape:IsDebuff()
    return false
end
function modifier_escape:IsPurgable()
    return false
end
function modifier_escape:IsPurgeException()
    return false
end
function modifier_escape:OnCreated(params)
    local hParent = self:GetParent()
    if IsServer() then
        hParent:Purge(true, true, false, true, true)
        hParent:SetHealth(hParent:GetMaxHealth())
    end
end
function modifier_escape:OnRefresh(params)
end
function modifier_escape:OnDestroy(params)
end
function modifier_escape:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DODGE_PROJECTILE
    }
end
function modifier_escape:CDeclareFunctions()
    return {
    }
end
function modifier_escape:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
    }
end
function modifier_escape:GetModifierDodgeProjectile()
    return 1
end
