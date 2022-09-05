--=======================================modifier_forcekill_custom=======================================
if modifier_forcekill_custom == nil then
    modifier_forcekill_custom = class({})
end
function modifier_forcekill_custom:IsHidden()
    return true
end
function modifier_forcekill_custom:IsDebuff()
    return false
end
function modifier_forcekill_custom:IsPurgable()
    return false
end
function modifier_forcekill_custom:IsPurgeException()
    return false
end
function modifier_forcekill_custom:OnCreated(params)
    if IsServer() then
        self:StartIntervalThink(0)
    end
end
function modifier_forcekill_custom:OnRefresh(params)
end
function modifier_forcekill_custom:OnDestroy(params)
end
function modifier_forcekill_custom:DeclareFunctions()
    return {
    }
end
function modifier_forcekill_custom:CDeclareFunctions()
    return {
    }
end
function modifier_forcekill_custom:OnIntervalThink()
    local hParent = self:GetParent()
    if hParent:IsAlive() then
        hParent:ForceKill(false)
    end
end