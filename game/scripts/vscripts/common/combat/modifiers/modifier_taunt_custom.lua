--modifiers
if modifier_taunt_custom == nil then
	modifier_taunt_custom = class({})
end
function modifier_taunt_custom:IsHidden()
    return false
end
function modifier_taunt_custom:IsDebuff()
    return true
end 
function modifier_taunt_custom:IsPurgable()
    return true
end
function modifier_taunt_custom:CheckState()
    return {
        [MODIFIER_STATE_TAUNTED] = true
    }
end
-- function modifier_taunt_custom:DeclareFunctions()
--     return {
--         MODIFIER_PROPERTY_OVERRIDE_ANIMATION
--     }
-- end
function modifier_taunt_custom:OnCreated(params)
    if IsServer() then
        local hParent = self:GetParent()
        local hCaster = self:GetCaster()
        hParent:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_DHPS)
    end
end
function modifier_taunt_custom:OnRefresh(params)
    if IsServer() then
        local hParent = self:GetParent()
        local hCaster = self:GetCaster()
        hParent:C_RefreshAggroTarget(AI_GET_TARGET_ORDER_DHPS)
    end
end