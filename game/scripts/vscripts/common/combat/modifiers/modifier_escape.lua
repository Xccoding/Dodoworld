--标记怪物逃跑用modifiers
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
function modifier_escape:OnCreated(params)
end
