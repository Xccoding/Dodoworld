--modifiers
if modifier_stun_custom == nil then
	modifier_stun_custom = class({})
end
function modifier_stun_custom:IsHidden()
    return true
end
function modifier_stun_custom:IsDebuff()
    return true
end 
function modifier_stun_custom:IsPurgable()
    return true
end
function modifier_stun_custom:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true
    }
end
function modifier_stun_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end
function modifier_stun_custom:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_stun_custom:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end
function modifier_stun_custom:GetOverrideAnimation()
    return ACT_DOTA_DISABLED
end