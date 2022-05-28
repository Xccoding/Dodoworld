--标记隐藏仇恨特效modifiers
if modifier_hide_aggro == nil then
	modifier_hide_aggro = class({})
end
function modifier_hide_aggro:IsHidden()
    return true
end
function modifier_hide_aggro:IsDebuff()
    return false
end 
function modifier_hide_aggro:IsPurgable()
    return false
end
function modifier_hide_aggro:OnCreated(params)
end
